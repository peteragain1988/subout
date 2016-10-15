class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token
  include Mongoid::Search

  ALL_REGIONS = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Missouri", "Mississippi", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
  ALL_VEHICLE_TYPES = ["Sedan", "Limo", "Party Bus", "Limo Bus", "Mini Bus", "Motorcoach", "Double Decker Motorcoach", "Executive Coach", "Sleeper Bus", "School Bus"]

  token field_name: :reference_number, retry_count: 7, length: 7, contains: :upper_alphanumeric

  field :name, type: String
  field :description, type: String
  field :start_location, type: String
  field :end_location, type: String
  field :start_region
  field :end_region
  field :special_region
  field :start_date, type: Date
  field :start_time, type: String
  field :end_date, type: Date
  field :end_time, type: String
  field :bidding_duration_hrs, type: String
  field :bidding_ends_at, type: Time
  field :bidding_done, type: Boolean, default: false
  field :quick_winnable, type: Boolean, default: false
  field :win_it_now_price, type: Money
  field :winning_bid_id, type: String
  field :seats, type: Integer
  field :type, type: String
  field :vehicle_type, type: String, default: ""
  field :vehicle_count, type: Integer, default: 1
  field :trip_type, type: String, default: ""
  field :canceled, type: Boolean, default: false
  field :awarded, type: Boolean, default: false
  field :in_negotiation, type: Boolean, default: false
  field :forward_auction, type: Boolean, default: false
  field :expired_notification_sent, type: Boolean, default: false
  field :completed_notification_sent, type: Boolean, default: false
  field :feedback_enabled, type: Boolean, default: false
  field :for_favorites_only, type: Boolean, default: false
  field :image_id
  field :tracking_id
  field :contact_phone, type: String
  field :value, type: Money, default: 0
  field :reserve_amount, type: Integer
  field :bidding_won_at, type: Time
  field :ada_required, type: Boolean, default: false

  field :for_quote_only, type: Boolean, default: false
  belongs_to :quote_request

  #if the regions have been changed we keep track of the old ones here so we know who's already been notified
  field :notified_regions, type: Array, default: [] 
  field :favorites_notified, type: Boolean, default: false

  index created_at: 1
  index start_date: 1
  index bidding_ends_at: 1

  index vehicle_type: 1
  index trip_type: 1
  index start_region: 1
  index end_region: 1

  index buyer_id: 1

  attr_accessor :viewer

  scope :active, -> { where(canceled: false, awarded: false) }
  scope :recent, -> { desc(:created_at) }
  scope :won, -> { where(:winning_bid_id.ne => nil) }
  scope :by_region, ->(region) { where(start_region: region) }
  scope :expired, -> { where(expired_notification_sent: true) }
  scope :by_period, ->(start_date, end_date) { where(:created_at.gte => start_date.beginning_of_day, :created_at.lte => end_date.end_of_day) }
  scope :last_12_hours, -> { where(:created_at.gte => 12.hours.ago) }
  
  belongs_to :buyer, class_name: "Company", inverse_of: :auctions, counter_cache: :auctions_count

  #has_one :event, as: :eventable
  has_many :bids, dependent: :destroy
  has_one :offer, dependent: :destroy

  embeds_many :comments
  belongs_to :winning_bid, :class_name => "Bid"

  validates :win_it_now_price, numericality: { greater_than: 0 }, unless: 'win_it_now_price.blank?'
  validates :bidding_duration_hrs, numericality: { greater_than: 0 }, presence: true
  validates :vehicle_count, numericality: { greater_than: 0}, unless: 'vehicle_count.blank?'
  validates_presence_of :buyer_id
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :start_date, if: '!is_for_special_region'
  validates_presence_of :end_date, if: '!is_for_special_region'
  validates_presence_of :start_location, if: '!is_for_special_region'
  #validates_presence_of :vehicle_type
  validate :validate_locations, if: '!is_for_special_region'
  validate :validate_start_and_end_date, if: '!is_for_special_region', on: :create
  validate :validate_win_it_now_price
  validate :validate_reseve_amount_and_win_it_now_price
  validate :validate_opportunity_post_limit

  #TODO this validation doesn't work correctly, if we enable this, it doesn't save any vehicle_type or trip_type
  #validates :vehicle_type, inclusion: { in: [nil, "Sedan", "Limo", "Party Bus", "Limo Bus", "Mini Bus", "Motorcoach", "Double Decker Motorcoach", "Executive Coach", "Sleeper Bus", "School Bus"] }
  #validates :trip_type, inclusion: { in: [nil, "One way", "Round trip", "Over the road"] }

  before_save :set_bidding_ends_at, unless: 'self.canceled'
  before_save :set_vehicle_count, if: 'self.vehicle_count.blank?'

  search_in :reference_number, :name

  paginates_per 30

  def self.create_from_quote_request!(quote_request)
    opportunity = Opportunity.new
    opportunity.name = quote_request.name
    opportunity.vehicle_type = quote_request.vehicle_type
    opportunity.vehicle_count = quote_request.vehicle_count
    opportunity.start_location = quote_request.start_location
    opportunity.start_date = quote_request.start_date
    opportunity.start_time = quote_request.start_time
    opportunity.start_region = quote_request.start_region
    opportunity.end_location = quote_request.end_location
    opportunity.end_region = quote_request.end_region
    opportunity.description = quote_request.description

    opportunity.canceled = false
    opportunity.awarded = false
    opportunity.bidding_duration_hrs = 48
    opportunity.winning_bid_id = nil
    opportunity.for_quote_only = true
    
    opportunity.quote_request = quote_request
    opportunity.save(:validate => false)
  end

  def is_for_special_region
    type == "Special" or type == "Buy or Sell Parts and Vehicles"
  end

  def companies_to_notify
    options = []
    if self.for_favorites_only?
      options << {:id.in => self.buyer.favorite_supplier_ids}
    else
      options << {:regions.in => regions}
    end
    companies = Company.active.any_of(*options).excludes(id: self.buyer_id) - notified_companies
    companies.select { |c| notify_to_vehicle_owner?(c.vehicle_types) }
  end

  def notified_companies
    options = []
    options << {:regions.in => notified_regions}
    options << {:id.in => self.buyer.favorite_supplier_ids} if favorites_notified?
    Company.any_of(*options)
  end

  def notify_companies(event_type)
    android_keys = []
    ios_keys = []

    companies_to_notify.each do |company|
      Notifier.delay_for(1.minutes).new_opportunity(self.id.to_s, company.id.to_s) if company.notification_items.include?("opportunity-new")
      Sms.new_opportunity(self, company) if company.cell_phone.present? && company.notification_items.include?("mobile-opportunity-new") # && self.emergency?

      user = company.users.first
      if company.notification_items.include?("mobile-opportunity-new")
        android_keys += user.mobile_keys.android.pluck(:key)
        ios_keys += user.mobile_keys.ios.pluck(:key)
      end
    end

    MobileKey.push_message_to_android(android_keys.uniq, {alert: self.name, extra:{id: self.id}}) if android_keys.any?
    MobileKey.push_message_to_ios(ios_keys.uniq, {alert: self.name, id: self.id}) if ios_keys.any?

    if self.for_favorites_only?
      self.update_attribute(:favorites_notified, true)
    else
      notified_regions = (self.regions + self.notified_regions).uniq
      self.update_attribute(:notified_regions, notified_regions) 
    end
  end

  def emergency?
    self.type == "Emergency"
  end

  def self.send_expired_notification
    where(:bidding_ends_at.lte => Time.now, expired_notification_sent: false, winning_bid_id: nil).each do |opportunity|
      if opportunity.buyer
        opportunity.buyer.inc(:auctions_expired_count=>1)
        Notifier.delay.expired_auction_notification(opportunity.id) if opportunity.buyer.notification_items.include?("opportunity-expire")
      end
      opportunity.set(:expired_notification_sent=>true)
    end
  end

  def self.send_completed_notification
    where(:end_date.lte => Date.today, completed_notification_sent: false, :winning_bid_id.ne => nil).each do |opportunity|
      Notifier.delay.completed_auction_notification_to_buyer(opportunity.id) if opportunity.buyer.notification_items.include?("opportunity-complete")
      Notifier.delay.completed_auction_notification_to_supplier(opportunity.id) if opportunity.winning_bid.bidder.notification_items.include?("opportunity-complete")
      opportunity.set(:completed_notification_sent=>true)
      opportunity.unlock_rating(opportunity.winning_bid.bidder.id, opportunity.buyer.id)
      opportunity.unlock_rating(opportunity.buyer.id, opportunity.winning_bid.bidder.id)
    end
  end

  def regions
    if is_for_special_region
      self.special_region == 'All' ? Opportunity::ALL_REGIONS : [self.special_region]
    else
      [self.start_region, self.end_region].compact
    end
  end

  def cancel!
    self.update_attributes(canceled: true, bidding_ends_at: Time.now)
  end

  def award!
    self.update_attributes(awarded: true, bidding_ends_at: Time.now)
  end

  def start_negotiation!(bid_id, new_amount)
    bid = self.bids.active.find(bid_id)

    if bid.amount.to_f == new_amount.to_f
      errors.add(:offer_amount, "should be different from current amount.") 
      return
    end

    unless bid.is_canceled?
      bid.state = "negotiating"
      bid.counter_amount = bid.amount
      bid.offer_amount = new_amount
      bid.amount = new_amount
      bid.save

      # send negotiation email to the bidder
      Notifier.delay.new_negotiation(bid.id)

      unless in_negotiation
        self.in_negotiation = true
        self.save(validate: false)
      end
    end
  end

  def win!(bid_id)
    bid = self.bids.active.find(bid_id)

    self.bidding_done = true
    self.awarded = true
    self.winning_bid_id = bid.id
    self.value = bid.amount
    self.bidding_won_at = Time.now
    self.save(validate: false) # when poster select winner, the start date validation may be failed

    bid.state = 'won'
    bid.save

    # update buyer info
    buyer = self.buyer
    buyer.total_sales += bid.amount.to_i
    buyer.save(validate: false)

    # update bidder info
    bidder = bid.bidder
    bidder.recent_winnings = bidder.recent_won_bid_amount
    bidder.total_winnings += bid.amount.to_i
    bidder.total_won_bids_count += 1
    bidder.save(validate: false)

    
    Notifier.delay.won_auction_to_buyer(self.id) if self.buyer.notification_items.include?("opportunity-win")
    Notifier.delay.won_auction_to_supplier(self.id) if bid.bidder.notification_items.include?("opportunity-win")
    
    if self.vehicle_count == bid.vehicle_count
      bid_loser_ids.each do |bidder_id|
        Notifier.delay.finished_auction_to_bidder(self.id, bidder_id)
      end
    else
      repost_for_more_vehicles!(self.vehicle_count - bid.vehicle_count)
    end
  end

  def repost_for_more_vehicles!(vehicle_count_diff)
    new_opportunity_attrs = self.attributes.except("_id", "reference_number", "created_at", "updated_at", "bidding_won_at", "value", "winning_bid_id", "bidding_done", "favorites_notified", "bidding_ends_at", "notified_regions")
    new_opportunity_attrs["vehicle_count"] = vehicle_count_diff
    new_opportunity_attrs["reserve_amount"] = self.reserve_amount / self.vehicle_count * new_opportunity_attrs["vehicle_count"].to_i unless self.reserve_amount.blank?
    new_opportunity_attrs["win_it_now_price"] = self.win_it_now_price / self.vehicle_count * new_opportunity_attrs["vehicle_count"].to_i unless self.win_it_now_price.blank?
    new_opportunity = Opportunity.create(new_opportunity_attrs)
    new_opportunity.update_value!

    self.bids.active.each do |old_bid|
      next if old_bid.id == self.winning_bid_id
      
      if old_bid.vehicle_count > new_opportunity.vehicle_count
        if old_bid.min_vehicle_count > new_opportunity.vehicle_count
          Notifier.delay.finished_auction_to_bidder(self.id, old_bid.bidder_id)
          next
        else
          #old_bid.amount = old_bid.amount.to_i / old_bid.vehicle_count * new_opportunity.vehicle_count
          old_bid.vehicle_count = new_opportunity.vehicle_count 
        end
      end

      old_bid.opportunity = new_opportunity
      old_bid.save
    end
  end

  def bid_loser_ids
    bidder_ids = self.bids.active.map(&:bidder_id)
    bidder_ids.reject! { |bidder_id| bidder_id == winning_bid.bidder_id }
    bidder_ids.uniq
  end

  def repost!
    new_opportunity_attrs = self.attributes.except("_id", "reference_number", "created_at", "updated_at", "bidding_won_at", "value", "winning_bid_id", "bidding_done", "favorites_notified", "bidding_ends_at", "notified_regions", "awarded")
    new_opportunity = Opportunity.create(new_opportunity_attrs)
  end

  def update!(options)
    if bids.active.any?
      errors.add(:base, "Opportunity cannot be updated if it already has a bid")
    else
      update_attributes(options)
    end
  end

  def winning_bid
    Bid.where(id: winning_bid_id, opportunity_id: id).first
  end

  def leading_bid_amount
    if forward_auction
      leading_bid, second_leading_bid = bids.active.sort_by { |b| -b.bidding_limit_amount }
      [second_leading_bid.bidding_limit_amount, leading_bid.bidding_limit_amount].min
    else
      leading_bid, second_leading_bid = bids.active.sort_by { |b| b.bidding_limit_amount }
      [second_leading_bid.bidding_limit_amount, leading_bid.bidding_limit_amount].max
    end
  end

  def bidding_ended?
    self.bidding_ends_at <= Time.now
  end

  def bidable?
    not(self.canceled? || self.awarded? || bidding_done? || self.winning_bid_id? || self.bidding_ended?)
  end

  def validate_locations
    unless DEVELOPMENT_MODE
      start_location_info = start_location.blank? ? nil : Geocoder.search(start_location).first
      self.start_region = start_location_info.try(:state)
      errors.add :start_location, "is not valid, please try again" unless valid_location?(start_location_info)

      end_location_info = end_location.blank? ? start_location_info : Geocoder.search(end_location).first
      self.end_region = end_location_info.try(:state)
      if !end_location.blank? and !valid_location?(end_location_info)
        errors.add :end_location, "is not valid, please try again"
      end
    else
      self.start_region = "Massachusetts" unless self.start_region
      self.end_region = "Massachusetts" unless self.end_region
    end
  end

  def fulltext
    [reference_number, name, description].join(' ')
  end

  def valid_location?(location)
    return false if location.blank?
    return false if location.country != "United States"
    return false if location.state.blank?
    true
  end

  def starts_at
    Time.parse("#{self.start_date} #{self.start_time}")
  end

  def ends_at
    Time.parse("#{self.end_date} #{self.end_time}")
  end

  def editable?
    return false if self.canceled? or self.awarded?
    not(self.bids.active.exists?)
  end

  def recent_bids
    result = self.bids.active.recent.map do |bid|
      bid.opportunity = self # to prevent loading opportunity again from db while serializing see BidShortSerializer#comment
      bid
    end
    result.uniq { |bid| bid.bidder_id }
  end

  def status
    if self.canceled?
      "Awarded"
    elsif self.winning_bid_id
      "Bidding won"
    elsif self.awarded?
      "Awarded"
    elsif self.bidding_ended?
      "Bidding ended"
    elsif self.in_negotiation?
      "In negotiation"
    else
      "In progress"
    end
  end

  def won?
    self.winning_bid_id.present?
  end

  def update_value!
    if self.won?
      value = self.winning_bid.amount 
    else
      value = forward_auction? ? highest_bid_amount : lowest_bid_amount
      value ||= 0
    end
    self.update_attribute(:value, value.to_i * 100)
  end

  def lowest_bid_amount
    self.bids.active.sort_by { |b| b.amount }.first.try(:amount)
  end

  def highest_bid_amount
    self.bids.active.sort_by { |b| -b.amount }.first.try(:amount)
  end

  def unlock_rating(rater_id, ratee_id)
    rating = Rating.find_or_create_by(rater_id: rater_id, ratee_id: ratee_id)
    rating.unlock!
  end

  def to_html
<<-EOS
    <p><strong>Title:</strong> #{self.name}</p>
    <p><strong>Pick up time:</strong> #{self.start_date} #{self.start_time}</p>
    <p><strong>Pick up location:</strong> #{self.start_location}</p>
    <p><strong>Drop off time:</strong> #{self.end_date} #{self.end_time}</p>
    <p><strong>Drop off location:</strong> #{self.end_location}</p>
    <p><strong>Vehicle Type:</strong> #{self.vehicle_type}</p>
    <p><strong>SO#:</strong> #{self.reference_number}</p>
    <p><strong>Description:</strong> #{self.description}</p>
EOS
  end

  private

  def set_bidding_ends_at
    created_time = self.created_at || Time.now
    self.bidding_ends_at = created_time + self.bidding_duration_hrs.to_i.hours
  end

  def set_vehicle_count
    self.vehicle_count = 1
  end

  def valid_time?(time)
    return false unless time
    begin
      Time.parse(time)
      true
    rescue ArgumentError
      false
    end
  end

  def validate_start_and_end_date
    unless valid_time?(start_time)
      errors.add(:start_time, "is invalid")
      return
    end

    unless valid_time?(end_time)
      errors.add(:end_time, "is invalid")
      return
    end

    errors.add(:start_date, "cannot be before now") if starts_at <= Time.now
    errors.add(:end_date, "cannot be before the start date") if ends_at < starts_at
  end

  def validate_win_it_now_price
    errors.add(:win_it_now_price, "cannot be blank in case 'Win it now?' option is enabled.") if self.quick_winnable && self.win_it_now_price.blank?
  end

  def validate_opportunity_post_limit
    if buyer.subscription_plan == 'free' and buyer.auctions.last_12_hours.count >= 5
      errors.add :base, "You cannot post opportunity over 5 times for 12 hours."
    end
  end

  def validate_reseve_amount_and_win_it_now_price
    return unless self.quick_winnable 
    return unless self.reserve_amount.present?
    return unless self.win_it_now_price.present?

    if self.forward_auction?
      errors.add(:reserve_amount, "cannot be more than win it now price") if self.reserve_amount > self.win_it_now_price
    else
      errors.add(:reserve_amount, "cannot be less than win it now price") if self.reserve_amount < self.win_it_now_price
    end
  end

  def notify_to_vehicle_owner?(vehicle_types)
    return true if vehicle_types.blank?
    return true if vehicle_type.blank?
    vehicle_types.include?(vehicle_type)
  end
end
