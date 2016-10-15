class QuoteRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  include Mongoid::Token
  include Mongoid::Search

  token field_name: :reference_number, retry_count: 7, length: 7, contains: :upper_alphanumeric

  VEHICLE_TYPES = {
    :"Motorcoach (47 to 56 passengers)"=>"Motorcoach",
    :"Mini Bus (up to 32 passenger)"=>"Mini Bus",
    :"School Bus (up to 40 adults or 60 kids)"=>"School Bus",
    :"Party Bus (up to 24 passengers)"=>"Party Bus",
    :"Sedan (up to 4 passengers)"=>"Sedan",
    :"Limo (up to 18 passengers)"=>"Limo",
    :"Limo Bus (up to 30 passengers)"=>"Limo Bus",
    :"Double Decker Motorcoach (up to 70 passenger)"=>"Double Decker Motorcoach",
    :"Executive Coach (up to 20 passengers)"=>"Executive Coach",
    :"Sleeper Bus (Sleep up to 12 passenger)"=>"Sleeper Bus"
  }

  TRIP_TYPES = {
    :"Church Trip"=>"Church Trip",
    :"Private Group"=>"Private Group",
    :"Athletic Group"=>"Athletic Group",
    :"Coroprate Group"=>"Coroprate Group",
    :"Airport"=>"Airport",
    :"Bachelor Party"=>"Bachelor Party",
    :"Bachelorette Party"=>"Bachelorette Party",
    :"Birthday"=>"Birthday",
    :"Camp"=>"Camp",
    :"Casino Outing"=>"Casino Outing",
    :"Church Function"=>"Church Function",
    :"Concert"=>"Concert",
    :"Convention"=>"Convention",
    :"Corporate Event"=>"Corporate Event",
    :"Cruise Transfers"=>"Cruise Transfers",
    :"Family Reunion"=>"Family Reunion",
    :"General Day Trip"=>"General Day Trip",
    :"Golf Outing"=>"Golf Outing",
    :"Night out on Town"=>"Night out on Town",
    :"Over the Road"=>"Over the Road",
    :"Prom"=>"Prom",
    :"Shuttle Service"=>"Shuttle Service",
    :"Sports Event"=>"Sports Event",
    :"Theme Park"=>"Theme Park",
    :"Transfer"=>"Transfer",
    :"Wedding"=>"Wedding",
    :"Other"=>"Other"
  }

  field :organization, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :phone, type: String
  field :vehicle_type, type: String
  field :vehicle_count, type: Integer
  field :passengers, type: Integer

  field :start_location, type: String
  field :start_location_address, type: String
  field :start_location_city, type: String
  field :start_location_state, type: String
  field :start_location_zip, type: String

  field :start_date, type: Date
  field :start_time, type: String
  field :start_region, type: String

  field :end_location, type: String
  field :end_location_address, type: String
  field :end_location_city, type: String
  field :end_location_state, type: String
  field :end_location_zip, type: String
  field :end_region, type: String

  field :departure_date, type: Date
  field :departure_time, type: String

  field :trip_type, type: String
  field :description, type: String

  field :retailer_host, type: String
  field :expired_notification_sent, type: Boolean, default: false

  field :state, type: String

  field :winning_quote_id, type: String
  field :awarded, type: Boolean, default: false
  field :bidding_won_at, type: Time

  field :agreement, type: Boolean, default: false

  attr_accessor :viewer
  
  index created_at: 1
  index start_date: 1

  index vehicle_type: 1
  index trip_type: 1
  index start_region: 1
  index end_region: 1
  index expired_notification_sent: 1
  index awarded: 1

  belongs_to :retailer
  has_many :quotes
  has_one :opportunity
  belongs_to :winning_quote, :class_name => "Quote"

  search_in :reference_number

  scope :not_expired, ->{ where(expired_notification_sent: false, awarded: false) }

  def fulltext
    [reference_number, name, description].join(' ')
  end
  validates :email, presence: true, email: true, confirmation: true
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :trip_type
  validates_presence_of :vehicle_type
  validates_presence_of :vehicle_count
  validates :vehicle_count, numericality: { greater_than: 0 }, unless: 'vehicle_count.blank?'

  validates_presence_of :passengers
  validates :passengers, numericality: { greater_than: 0 }, unless: 'passengers.blank?'

  validates_presence_of :start_location_address, :start_location_city, :start_location_state, :start_location_zip
  validates_presence_of :start_date
  validates :start_date, date: { message: "is invalid date format (mm/dd/yyyy)" }, :if=>"!start_date.blank?"

  validates_presence_of :start_time
  validate :validate_start_time, :if=>"!start_time.blank?"
  validate :validate_dates

  validates_presence_of :end_location_address, :end_location_city, :end_location_state, :end_location_zip
  validates_presence_of :description
  validate :validate_locations
  # validates_presence_of :agreement

  before_validation :set_locations

  def validate_start_time
    errors.add(:start_time, "is invalid time format") if !valid_time?(self.start_time)
  end

  def recent_quotes
    result = self.quotes.active.recent.map do |quote|
      quote.quote_request = self # to prevent loading opportunity again from db while serializing see BidShortSerializer#comment
      quote
    end
    result.uniq { |quote| quote.quoter_id }
  end

  def name
    if !self.organization.blank?
      return "#{first_name}, #{last_name} of #{organization}"
    else
      return "#{first_name}, #{last_name}"
    end
  end

  def quotes_html
    self.recent_quotes.map{|quote| quote.to_html(true)}.join('')
  end

  def status
    if self.winning_quote_id
      "Bidding won"
    elsif self.awarded?
      "Awarded"
    elsif self.bidding_ended?
      "Bidding ended"
    else
      "In progress"
    end
  end

  def bidding_ended?
    self.created_at < 2.days.ago
  end

  def quotable?
    !self.bidding_ended? && !self.awarded?
  end

  def validate_dates
    unless valid_time?(start_time)
      return
    end
    errors.add(:start_date, "cannot be before now") if starts_at <= Time.now
  end

  def starts_at
    Time.parse("#{self.start_date.to_date} #{self.start_time}")
  end

  def departures_at
    Time.parse("#{self.departure_date.to_date} #{self.departure_time}")
  end

  def regions
    [self.start_region, self.end_region].compact
  end

  def validate_locations
    unless DEVELOPMENT_MODE
      start_location_info = start_location.blank? ? nil : Geocoder.search(start_location).first
      self.start_region = start_location_info.try(:state)
      errors.add :start_location, "is not valid" unless valid_location?(start_location_info)

      end_location_info = end_location.blank? ? start_location_info : Geocoder.search(end_location).first
      self.end_region = end_location_info.try(:state)
      if !end_location.blank? and !valid_location?(end_location_info)
        errors.add :end_location, "is not valid"
      end
    else
      self.start_region = "Massachusetts" unless self.start_region
      self.end_region = "Massachusetts" unless self.end_region
    end
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

  def valid_location?(location)
    return false if location.blank?
    return false if location.country != "United States"
    return false if location.state.blank?
    true
  end

  def win!(quote_id)
    self.opportunity.awarded = true
    self.opportunity.save(validate: false)

    quote = self.quotes.active.find(quote_id)
    quoter = quote.quoter

    self.awarded = true
    self.state = 'won'
    self.winning_quote_id = quote.id
    self.bidding_won_at = Time.now
    self.save(validate: false) # when poster select winner, the start date validation may be failed

    quote.state = 'won'
    quote.save

    quoter.total_winnings += quote.amount.to_i
    quoter.total_won_bids_count += 1
    quoter.save(validate: false)

    Notifier.delay.won_quote_to_consumer(self.id)
    Notifier.delay.won_quote_to_quoter(self.id) if quoter.notification_items.include?("opportunity-win")
  end

  def notify_companies
    Company.active.each do |company|
      Notifier.delay_for(1.minutes).new_quote_request(self.id, company.id) if company.notification_items.include?("opportunity-new")
    end
  end

  def self.send_expired_notification
    where(:created_at.lte => 2.days.ago, expired_notification_sent: false).each do |quote_request|
      Notifier.delay.expired_quote_request(quote_request.id)
      quote_request.set(:state=>'expired')
      quote_request.set(:expired_notification_sent=>true)
    end
  end

  def to_html
    [
      "<strong>Vehicle type:</strong> #{vehicle_type}",
      "<strong>Vehicle count:</strong> #{vehicle_count}",
      "<strong>Passengers:</strong> #{passengers}",
      "<strong>Pick up address:</strong> #{start_location}",
      "<strong>Pick up date:</strong> #{starts_at.to_s(:long)}",
      "<strong>Drop off address:</strong> #{end_location}",
      "<strong>Departure date:</strong> #{departures_at.to_s(:long)}",
      "<strong>Trip type:</strong> #{trip_type}",
      "<strong>Description:</strong> #{description}",
    ].join("<br>")
  end

  private
  def set_locations
    self.start_location = "#{self.start_location_address} #{self.start_location_city} #{self.start_location_state} #{self.start_location_zip}"
    self.end_location = "#{self.end_location_address} #{self.end_location_city} #{self.end_location_state} #{self.end_location_zip}"
  end

end
