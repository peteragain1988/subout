require 'my_chargify'

class GatewaySubscription
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  REGION_NAMES = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York' , 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', '
    Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas' , 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']

  field :email
  field :first_name
  field :last_name
  field :organization
  field :subscription_id
  field :customer_id
  field :product_handle
  field :vehicle_count, type: Integer, default: 0
  field :confirmed, type: Boolean, default: false
  field :state
  field :payment_state
  field :card_expired_date, type: Date
  field :card_expired_email_sent, type: Boolean, default: false
  field :remind_email_sent, type: Boolean, default: false
  field :tac_agreement, type: Boolean, default: false
  field :tac_agreement_at, type: Time

  search_in :email, :id, :first_name, :last_name, :organization, :subscription_id, :customer_id, :product_handle

  has_one :created_company, class_name: "Company", inverse_of: :created_from_subscription
  # attr_accessible :product_handle, :subscription_id, :customer_id, :email, :first_name, :last_name, :organization, :state

  after_save :update_chargify_email, if: "self.email_changed?"

  scope :pending, -> { where(confirmed: false) }
  scope :recent, -> { desc(:created_at) }

  validates :subscription_id, uniqueness: true

  def self.send_remind_notification
    GatewaySubscription.where(confirmed: false, remind_email_sent: false, :created_at.lte => 3.days.ago).each do |gw|
      Notifier.delay.remind_registration_to_user(gw.id)
      Notifier.delay.remind_registration_to_admin(gw.id)
      gw.update_attribute(:remind_email_sent, true)
    end
  end

  def self.revenues(options)
    result = Hash.new

    start_date = Date.parse(options[:start_date])
    end_date = Date.parse(options[:end_date])

    GatewaySubscription::REGION_NAMES.each do |region|
      tmp_value = Hash.new
      tmp_value[:posted_oppor_count] = Opportunity.by_region(region).by_period(start_date, end_date).count
      tmp_value[:total_awarded_count] = Opportunity.by_region(region).by_period(start_date, end_date).won.count
      tmp_value[:total_awarded_amount] = Opportunity.by_region(region).by_period(start_date, end_date).won.sum(&:value)
      result[region] = tmp_value
    end

    if options[:sort_order] == 'asc'
      result.sort_by{ |key, value| value[options[:sort_by].to_sym] }
    else
      result.sort_by{ |key, value| value[options[:sort_by].to_sym] }.reverse
    end
  end

  def confirm!
    update_attribute(:confirmed, true)
  end

  def pending?
    !confirmed
  end

  def company_last_sign_in_at
    self.created_company.try(:last_sign_in_at)
  end

  def self.by_category(category)
    if category == "registered"
      scoped.where(confirmed: true)
    elsif category == "not_registered"
      scoped.where(confirmed: false)
    else
      scoped
    end
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def created_company_name
    self.created_company.try(:name)
  end

  def subscription_url
    subscription_id.blank? ? "" : "https://#{CHARGIFY_URI}/subscriptions/#{subscription_id}"
  end

  def subscription_payment_profiles_url
    subscription_id.blank? ? "" : "https://#{CHARGIFY_URI}/subscriptions/#{subscription_id}/payment_profiles"
  end

  def customer_url
    customer_id.blank? ? "" : "https://#{CHARGIFY_URI}/customers/#{customer_id}"
  end

  def self.csv_column_names
    ["_id","email", "name", "organization", "subscription_url", "customer_url", "product_handle", "confirmed", "created_company_name"]
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << csv_column_names
      all.each do |item|
        csv << csv_column_names.map { |column| item.send(column) }
      end
    end
  end

  def update_vehicle_count!(vehicle_count)
    return if self.product_handle != 'subout-pro-service' 

    if cs = chargify_subscription
      bus_component = cs.components.first
      bus_component.allocated_quantity = vehicle_count > 2 ? vehicle_count - 2 : 0
      bus_component.save

      self.vehicle_count = vehicle_count
      self.save
    end
  end

  def update_product!(product_handle)
    if cs = chargify_subscription
      cs.product_handle = product_handle
      cs.save

      created_company.vehicles.destroy_all if product_handle == 'free'

      self.product_handle = product_handle
      self.save

      if company = self.created_company
        company.set_subscription_info
        company.save
      end
    end
  end

  def exists_on_chargify?
    Chargify::Subscription.exists?(self.subscription_id)
  end

  def chargify_subscription
    Chargify::Subscription.find(self.subscription_id)
  rescue
    nil
  end

  def cancel!
    if subscription = chargify_subscription and subscription.state != 'canceled'
      subscription.cancel
    end
  end

  def canceled?
    if Rails.env.production?
      if subscription = chargify_subscription and subscription.state == 'canceled'
        return true
      end
      return false
    else
      self.state == 'canceled'
    end
  end

  def reactivate!
    if subscription = chargify_subscription and subscription.state == 'canceled'
      subscription.reactivate
    end
  end

  def update_chargify_email
    customer = Chargify::Customer.find(self.customer_id)
    customer.email = self.email
    customer.save
  end
  
  def self.send_expired_card_notification
    GatewaySubscription.all.each do |gs|
      next if gs.created_company.nil? or gs.state != 'active' or gs.product_handle == 'free'

      gs.update_credit_card_expired

      if gs.card_expired_date
        if (gs.card_expired_date > 10.days.ago.to_date) and !gs.card_expired_email_sent
          Notifier.delay.expired_card(gs.created_company.id) if gs.created_company.notification_items.include?("account-expired-card")
          gs.set(card_expired_email_sent: true)
        elsif gs.card_expired_date == 10.days.ago.to_date
          gs.created_company.lock_access!
          Notifier.delay.locked_company(gs.created_company.id) if gs.created_company.notification_items.include?("account-locked")
        end
      end
    end
  end

  def credit_card_info
    cs = chargify_subscription
    return unless cs.present?
    cs.try(:credit_card)
  rescue
    false
  end

  def has_valid_credit_card?
    cc = credit_card_info
    return false unless cc.present?

    Time.new(cc.expiration_year, cc.expiration_month) > Time.now.beginning_of_month
  end

  def update_credit_card_expired
    unless has_valid_credit_card?
      self.card_expired_date = Time.now if self.card_expired_date.nil?
    else
      self.card_expired_date = nil
      self.card_expired_email_sent = false
    end
    self.save
  end

  def accept_tac!(acceptance, time)
    self.tac_agreement = acceptance
    self.tac_agreement_at = time
    self.save
  end  

end
