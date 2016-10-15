class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  # attr_protected :logo_url, :vehicles
  field :name, type: String
  field :email, type: String

  field :fleet_size, type: String
  field :since, type: String
  field :owner, type: String
  field :contact_name, type: String
  field :contact_phone, type: String
  field :tpa, type: String
  field :website
  field :prelaunch, type: Boolean
  field :logo_id
  field :abbreviated_name
  field :dot_number, type: String
  field :insurance, type: String
  field :cell_phone, type: String

  field :address_line1, type: String
  field :address_line2, type: String
  field :city, type: String
  field :state, type: String
  field :country, type: String
  field :zip_code, type: String

  field :favorite_supplier_ids, type: Array, default: []
  field :favoriting_buyer_ids, type: Array, default: []
  field :created_from_invitation_id
  field :created_from_subscription_id

  field :subscription_plan, default: 'free'
  field :regions, type: Array, default: []

  field :notification_type, default: 'Individual'
  field :notification_email, type: String
  field :bad_email, type: Boolean, default: false

  field :total_sales, type: Integer, default: 0
  field :total_winnings, type: Integer, default: 0
  field :total_won_bids_count, type: Integer, default: 0
  field :recent_winnings, type: Integer, default: 0

  field :last_upgraded_at, type: Time
  field :has_ada_vehicles, type: Boolean, default: false
  field :locked_at, type: Time
  field :vehicle_types, type: Array, default: []
  field :payment_methods, type: Array, default: []
  field :poster_message

  field :active, type: Boolean
  field :tac_agreement, type: Boolean, default: false
  field :tac_agreement_at, type: Time
  field :company_msg_path, type: String, default: ->{ SecureRandom.uuid }
  field :member, type: Boolean, default: false
  field :auctions_count, type: Integer, default: 0
  field :auctions_expired_count, type: Integer, default: 0
  field :bids_count, type: Integer, default: 0
  field :notification_items, type: Array, default: ["opportunity-new", "opportunity-win", "account-locked", "account-expired-card"]
  field :offerer, type: Boolean, default: false

  Company::MODES = ['normal', 'ghost', 'benefit']
  field :mode, type: String, default: 'normal'

  scope :recent, -> { desc(:created_at) }
  scope :active, -> { where(:locked_at=>nil) }

  attr_accessor :password, :password_confirmation
  # attr_protected :ratings_taken

  belongs_to :created_from_invitation, class_name: 'FavoriteInvitation', inverse_of: :created_company
  belongs_to :created_from_subscription, class_name: 'GatewaySubscription', inverse_of: :created_company

  has_many :ratings_given, class_name: 'Rating', inverse_of: :rater 
  has_many :ratings_taken, class_name: 'Rating', inverse_of: :ratee

  has_many :users
  has_many :vehicles
  has_many :auctions, class_name: "Opportunity", foreign_key: 'buyer_id'
  has_many :bids, foreign_key: 'bidder_id'
  has_many :quotes, foreign_key: 'quoter_id'

  accepts_nested_attributes_for :users

  validates :name, presence: true
  validates :abbreviated_name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, email: true
  validates :notification_email, email: true, :allow_blank => true
  validates_confirmation_of :password

  #validates :address_line1, presence: true
  #validates :city, presence: true
  #validates :state, presence: true
  #validates :country, presence: true
  #validates :zip_code, presence: true


  # FIXME: Thomas Total Hack
  # validates_presence_of :created_from_invitation_id, :on => :create, unless: 'created_from_subscription_id.present?'
  validate :validate_invitation, :on => :create, if: "created_from_invitation_id.present?"
  validate :validate_subscription, :on => :create, if: "created_from_subscription_id.present?"
  validate :check_nils

  before_create :set_subscription_info
  before_save :set_notification_items
  after_create :accept_invitation!, if: "created_from_invitation_id.present?"
  after_create :confirm_subscription!, if: "created_from_subscription_id.present?"

  search_in :name, :email

  def recent_won_bid_amount
    self.bids.between(created_at: 90.days.ago..Time.now).won.sum(&:amount)
  end

  def last_years_won_bid_amount
    self.bids.between(created_at: 1.year.ago.beginning_of_year..1.year.ago.end_of_year).won.sum(&:amount)
  end

  def this_years_won_bid_amount
    self.bids.since(1.year.ago).won.sum(&:amount)
  end

  def has_subscription_benefit?
    self.mode == "ghost" or self.mode == "benefit" or self.subout_free_subscriber?
  end

  def self.send_daily_remind_notification
    Company.where(:notification_items => ['daily-reminder']).each do |company|
      Notifier.delay.daily_reminder(company.id)
    end
  end

  def check_nils
    errors.add(:favorite_supplier_ids, "is not defined") if favorite_supplier_ids.nil?
    errors.add(:favoriting_buyer_ids, "is not defined") if favoriting_buyer_ids.nil?
  end

  def notifiable_email
    return email if notification_email.blank?
    notification_email
  end

  def notifiable?
    if created_from_subscription and created_from_subscription.state == 'canceled'
      return false
    end

    return true
  end

  def favorite_suppliers
    Company.where(:id.in => self.favorite_supplier_ids)
  end

  def favoriting_buyers
    Company.where(:id.in => self.favoriting_buyer_ids)
  end

  def add_favorite_supplier!(supplier)
    self.favorite_supplier_ids << supplier.id
    self.save

    supplier.favoriting_buyer_ids << ::BSON::ObjectId.from_string(self.id)
    supplier.save

    unless DEVELOPMENT_MODE
      Pusher['global'].trigger!('added_to_favorites', company_id: self.id, supplier_id: supplier.id)
    end
  end

  def remove_favorite_supplier!(supplier)
    self.favorite_supplier_ids.delete( supplier.id )
    self.save

    supplier.favoriting_buyer_ids.delete( self.id )
    supplier.save

    unless DEVELOPMENT_MODE
      Pusher['global'].trigger!('removed_from_favorites', company_id: self.id, supplier_id: supplier.id)
    end
  end

  def subout_pro_subscriber?
    subscription_plan == 'subout-pro-service'
  end

  def subout_basic_subscriber?
    subscription_plan == 'subout-basic-service'  
  end

  def subout_free_subscriber?
    subscription_plan == 'free'  
  end

  def has_canceled_subscription?
    subscription = self.created_from_subscription
    return true if subscription and subscription.chargify_subscription and subscription.state == 'canceled'
    return false
  end

  def create_initial_user!
    return unless users.empty?
    users.create!(email: email, password: password)
  end

  def inviter
    self.created_from_invitation.buyer
  end

  def self.companies_for(company)
    company.abbreviated_name = "Self"
    [company] + Company.ne(id: company.id).to_a
  end

  def set_subscription_info
    if subscription = created_from_subscription
      self.subscription_plan = subscription.product_handle
    else
      self.subscription_plan = "free"
    end
  end

  def last_sign_in_at
    first_user.try(:last_sign_in_at)
  end

  def first_user
    @first_user ||= self.users.to_a.first
  end

  def auth_token_hash
    if first_user.present?
      first_user.auth_token_hash
    else
      {}
    end
  end

  def is_a_favorite_of?(other_company) 
    self.favoriting_buyer_ids.include?(other_company.id)
  end

  def available_opportunities(sort_by = :bidding_ends_at, sort_direction = 'asc', start_date = nil, vehicle_types=nil, trip_type=nil, query=nil, regions=nil)
    start_date = nil if start_date == "null" or start_date.blank?
    begin
      unless start_date.nil?
        date = Date.parse(start_date) 
        start_date = date.to_s 
      end
    rescue ArgumentError
      start_date = nil
    end

    sort_by ||= :bidding_ends_at
    sort_direction ||= "asc"
    vehicle_types = nil if vehicle_types == "null" or vehicle_types.blank?
    trip_type = nil if trip_type == "null" or trip_type.blank?
    regions = nil if regions == "null"

    vehicle_types = vehicle_types.split(',') unless vehicle_types.nil?

    if regions.nil?
      regions = self.regions
    else
      regions = regions.split(',')
    end

    options = []
    unless regions.blank?
      options << {:start_region.in => regions}
      options << {:end_region.in => regions}
      options << {:special_region.in => regions + ['All']}
    end

    conditions = {
      canceled: false,
      awarded: false,
      :bidding_ends_at.gt => Time.now,
      winning_bid_id: nil,
      :buyer_id.ne => self.id
    }

    conditions[:vehicle_type.in] = vehicle_types unless vehicle_types.blank?
    conditions[:start_date] = start_date if start_date
    conditions[:trip_type] = trip_type if trip_type
    opportunities = Opportunity.any_of(*options).where(conditions)
    
    opportunities = opportunities.search(query) if query.present?
    opportunities.order_by(sort_by => sort_direction)
  end

  def sales_info_messages
    sales_messages = []
    sales_messages << "#{ActionController::Base.helpers.number_to_currency(total_sales, precision: 0)} in sales" if total_sales > 0
    sales_messages << "#{ActionController::Base.helpers.number_to_currency(total_winnings, precision: 0)} in winnings" if total_winnings > 0
    sales_messages << "Bid on #{opportunities_bid_on.size} opportunities worth #{ActionController::Base.helpers.number_to_currency(opportunities_bid_on.sum(&:value), precision: 0)}" if bids.count > 0

    sales_messages << "No activity so far" if sales_messages.empty?

    sales_messages
  end

  def opportunities_bid_on
    Opportunity.where(:id.in => self.bids.distinct(:opportunity_id))
  end

  def sign_up_errors
    sign_up_errors = self.errors.to_hash
    if user = self.users.first and !user.valid?
      sign_up_errors.delete(:users)
      sign_up_errors.merge!(user.errors.to_hash)
    end
    sign_up_errors
  end

  def self.sort(sort_by, direction)
    scoped.order_by(sort_by => direction)
  end

  def update_regions!(regions)
    regions ||= []
    self.regions = regions
    self.save
  end

  def update_vehicles!(vehicle_list)
    vehicle_list ||= []
    
    vehicles.not_in(id: vehicle_list.map{|v| v[:_id]}).destroy_all

    vehicle_list.each do |vehicle|
      v = Vehicle.where(id: vehicle[:_id]).first
      if v
        old_vehicle = v.clone
        v.assign_attributes(vehicle.except(:created_at, :updated_at, :rm_number)) 
        if v.changed?
          v.save
          Notifier.delay.update_vehicle(v.id, old_vehicle)
        end
      else
        self.vehicles << Vehicle.create(vehicle)
      end
    end
    self.save

    update_vehicle_count()
  end

  def update_vehicle_count()
    subscription = self.created_from_subscription
    return unless subscription

    if subscription.vehicle_count != self.vehicles.count
      subscription.update_vehicle_count!(self.vehicles.count)
    end

    true
  end

  def update_product!(product)
    products = ["free", "subout-basic-service", "subout-pro-service"]

    upgrading = products.index(product) > products.index(self.subscription_plan) 

    if self.upgraded_recently && !upgrading
      errors.add(:base, "You upgraded your plan recently. You couldn't downgrade within a month.")
      return false
    else
      self.last_upgraded_at = Time.now if upgrading 
      self.save
      self.created_from_subscription.update_product!(product) if self.created_from_subscription 
    end
  end

  def vehicles_count
    self.vehicles.count
  end

  def chargify_subscription_id
    self.created_from_subscription.subscription_id rescue nil
  end

  def chargify_customer_id
    self.created_from_subscription.customer_id rescue nil
  end

  def self.csv_column_names
    [
      "_id","email", "name", "owner", "contact_name", "contact_phone", "mode", "created_at",
      "last_sign_in_at", "subscription_plan", "vehicles_count", "auctions_count", "auctions_expired_count", 
      "bids_count", "total_won_bids_count", "total_winnings", "access_locked?", "chargify_subscription_id", "chargify_customer_id", "tpa"
    ]
  end

  def csv_value_for(column)
    send(column)
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << csv_column_names
      all.each do |item|
        csv << csv_column_names.map { |column| item.csv_value_for(column) }
      end
    end
  end

  def to_csv
    Company.csv_column_names.map { |column| self.csv_value_for(column) }.to_csv
  end

  def upgraded_recently
    last_upgraded_at = self.last_upgraded_at || self.created_at
    last_upgraded_at > 1.month.ago
  end

  def access_locked?
    self.locked_at.present?
  end

  def lock_access!
    users.each(&:lock_access!)
    self.update_attribute(:locked_at, Time.now)
  end

  def unlock_access!
    users.each(&:unlock_access!)
    self.update_attribute(:locked_at, nil)
  end
  
  def change_emails!(email)
    self.update_attribute(:email, email)
    self.created_from_subscription.update_attribute(:email, email)
    self.users.first.update_attribute(:email, email)
  end

  def chargify_service_url
    MyChargify.self_service_url(self.created_from_subscription.try(:subscription_id))
  end

  def to_html
<<-EOS
    <p><strong>Name:</strong> #{self.name}</p>
    <p><strong>Email:</strong> #{self.email}</p>
    <p><strong>Contact phone:</strong> #{self.contact_phone}</p>
    <p><strong>Website:</strong> #{self.website}</p>
EOS
  end

  def accept_tac!(acceptance=true, time=nil)
    self.tac_agreement = acceptance || true
    self.tac_agreement_at = time || Time.now
    self.save

    update_subscription_tac!
  end 

  def update_subscription_tac!
    self.created_from_subscription.accept_tac!(self.tac_agreement, self.tac_agreement_at) if self.created_from_subscription
  end

  private

  def set_notification_items
    self.notification_items = [] if self.notification_items.nil?
  end

  def validate_invitation
    return if self.created_from_invitation && self.created_from_invitation.pending?

    errors.add(:created_from_invitation_id, "Invalid invitation")
  end

  def validate_subscription
    return if self.created_from_subscription && self.created_from_subscription.pending?

    errors.add(:created_from_subscription_id, "Invalid subscription")
  end

  def accept_invitation!
    self.created_from_invitation.accept!
  end

  def confirm_subscription!
    self.created_from_subscription.confirm!
  end

end
