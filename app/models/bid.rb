class Bid
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  STATES = %w(active canceled negotiating won declined)

  token field_name: :reference_number, retry_count: 7, length: 7, contains: :upper_alphanumeric

  field :amount, type: Money
  field :offer_amount, type: Money
  field :counter_amount, type: Money

  field :comment, type: String
  field :auto_bidding_limit, type: Money
  field :canceled, type: Boolean, default: false
  field :vehicle_count, type: Integer, default: 1
  field :vehicle_count_limit, type: Integer
  field :state, type: String, default: "active"
  field :token, type: String

  paginates_per 30

  embeds_many :vehicles, class_name: 'BidVehicle'

  belongs_to :opportunity, :inverse_of => :bids
  belongs_to :bidder, class_name: "Company", counter_cache: :bids_count
  belongs_to :quote

  has_one :won_opportunity, :class_name => "Opportunity", :foreign_key => "winning_bid_id", :inverse_of => :winning_bid

  index bidder_id: 1
  index opportunity_id: 1

  validates_presence_of :bidder_id, on: :create, message: "can't be blank"
  validates_presence_of :opportunity_id, on: :create, message: "can't be blank"
  validates_presence_of :amount, on: :create, message: "can't be blank"
  validates :amount, numericality: { greater_than: 0 }
  validates :vehicle_count, numericality: { greater_than: 0}, allow_blank: true
  validates :vehicle_count_limit, numericality: { greater_than: 0}, allow_blank: true
  validates :offer_amount, numericality: { greater_than: 0}, allow_blank: true
  validates :counter_amount, numericality: { greater_than: 0}, allow_blank: true

  validate :validate_opportunity_bidable, on: :create
  validate :validate_bidable_by_bidder, on: :create
  validate :validate_multiple_bids_on_the_same_opportunity, on: :create
  #validate :validate_reserve_met, on: :create
  validate :validate_dot_number_of_bidder, on: :create
  validate :validate_auto_bidding_limit, on: :create
  validate :validate_auto_bidding_limit_on_win_it_now_price, on: :create
  validate :validate_ada_required, on: :create
  validate :vehicle_count_bidable, on: :create
  validate :vehicle_count_limit_bidable, on: :create
  validates :comment, length: { maximum: 255 }

  scope :active, -> { where(:state.ne => 'canceled') }
  scope :recent, -> { desc(:created_at) }
  scope :by_amount, -> { asc(:amount) }
  scope :today, -> { where(:created_at.gte => Date.today.beginning_of_day, :created_at.lte => Date.today.end_of_day) }
  scope :month, -> { where(:created_at.gte => Date.today.beginning_of_month, :created_at.lte => Date.today.end_of_month) }
  scope :last_90_days, -> { where(:created_at.gte => 90.days.ago, :created_at.lte => Time.now) }
  scope :won, -> { where(:state => 'won') }

  after_create :win_quick_winable_opportunity
  after_create :run_automatic_bidding


  STATES.each do |value|
    define_method :"is_#{value}?" do 
      self.state == value
    end
  end

  def self.create_from_quote(quote)
    bid = Bid.new
    bid.amount = quote.amount
    bid.opportunity = quote.quote_request.opportunity
    bid.bidder = quote.quoter
    bid.quote = quote
    bid.save(:validate => false)
  end

  def set_onetime_token!
    self.token = SecureRandom.base64(32)
    self.save
  end

  def status
    if is_canceled?
      "Canceled by you"
    elsif opportunity.status == "Canceled"
      "Canceled by poster"
    elsif opportunity.status == "Bidding won"
      opportunity.winning_bid_id == id ? "Won" : "Not won"
    elsif opportunity.awarded?
      "Closed"
    elsif opportunity.status == "Bidding ended"
      "Closed"
    elsif is_negotiating? 
      "In negotiation"
    elsif is_declined?
      "Declined"
    else
      "In progress"
    end
  end

  def comment_as_seen_by(viewer)
    (viewer == bidder || viewer == opportunity.buyer) ? comment : ""
  end

  def bidding_limit_amount
    auto_bidding_limit ? auto_bidding_limit : amount
  end

  def min_vehicle_count
    vehicle_count_limit ? vehicle_count_limit : vehicle_count
  end

  def cancel
    if created_at < 12.hours.ago
      errors.add(:base, "You cannot cancel a bid after 12 hours")
      false
    else
      self.state = 'canceled'
      self.save
    end
  end

  def cancel!
    self.state = 'canceled'
    self.save
  end

  def decline!
    self.state = 'declined'
    self.save
  end

  def counter_negotiation!(new_amount)
    if self.amount.to_f == new_amount.to_f
      return errors.add(:offer_amount, "should be different from current amount.") 
    end
    self.amount = new_amount
    self.counter_amount = new_amount
    self.state = "negotiating"
    self.save

    Notifier.delay.counter_negotiation(self.id) 
  end

  private

  def win_quick_winable_opportunity
    return unless opportunity.quick_winnable

    opportunity.win!(self.id) if quick_win_forward_auction? or quick_win_reverse_auction?
  end

  def quick_win_forward_auction?
    opportunity.forward_auction? and opportunity.win_it_now_price <= self.amount
  end

  def quick_win_reverse_auction?
    !opportunity.forward_auction? and opportunity.win_it_now_price >= self.amount 
  end

  def validate_opportunity_bidable
    return unless opportunity

    unless opportunity.bidable?
      errors.add :base, "opportunity has been closed"
    end
  end

  def validate_bidable_by_bidder
    return unless opportunity

    if !bidder.is_a_favorite_of?(opportunity.buyer)
      if opportunity.for_favorites_only?
        errors.add :bidder_id, "cannot bid on an opportunity that is for favorites only"
      end
    end

    if bidder.subscription_plan == 'free' and bidder.bids.month.count >= 5
      errors.add :base, "You cannot bid over 5 times per month."
    end
  end

  def validate_multiple_bids_on_the_same_opportunity
    return unless opportunity
    return if errors[:amount].present?

    previous_bids = opportunity.bids.active.where(bidder_id: bidder.id, :id.ne => self.id)
    if opportunity.forward_auction?
      max_amount = previous_bids.map(&:amount).max
      if max_amount && amount <= BigDecimal.new(max_amount.to_s)
        errors.add :amount, "cannot be lower or equal to previous bid.($#{max_amount})"
      end
    else
      min_amount = previous_bids.map(&:amount).min
      if min_amount && amount >= BigDecimal.new(min_amount.to_s)
        errors.add :amount, "cannot be higher or equal to previous bid.($#{min_amount})"
      end
    end
  end

  # we don't use this validation according to story #56069204
  def validate_reserve_met
    return unless opportunity
    return unless opportunity.reserve_amount.present?
    return if errors[:amount].present?

    if opportunity.forward_auction?
      if amount < opportunity.reserve_amount
        errors.add :amount, "cannot be lower than reserve"
      end
    else
      if amount > opportunity.reserve_amount
        errors.add :amount, "cannot be higher than reserve"
      end
    end
  end

  def validate_dot_number_of_bidder
    return unless bidder

    if bidder.dot_number.blank?
      errors.add :bidder_id, "required DOT number to bid."
    end
  end

  def validate_auto_bidding_limit
    return unless opportunity
    return unless auto_bidding_limit.present?
    return if errors[:amount].present?

    if opportunity.forward_auction? and amount > auto_bidding_limit 
      errors.add :auto_bidding_limit, "cannot be lower than amount."
    end

    if !opportunity.forward_auction? and amount < auto_bidding_limit 
      errors.add :auto_bidding_limit, "cannot be higher than amount."
    end
  end

  def validate_auto_bidding_limit_on_win_it_now_price
    return unless opportunity
    return unless auto_bidding_limit.present?
    return unless opportunity.quick_winnable

    if opportunity.forward_auction? and opportunity.win_it_now_price <= auto_bidding_limit
      errors.add :auto_bidding_limit, "cannot be lower than win it now price."
    end

    if !opportunity.forward_auction? and opportunity.win_it_now_price >= auto_bidding_limit
      errors.add :auto_bidding_limit, "cannot be higher than win it now price."
    end
  end

  def validate_ada_required
    return unless opportunity

    if opportunity.ada_required? and !bidder.has_ada_vehicles?
      errors.add :base, "Please indicate that your fleet includes ADA vehicles before continuing."
    end
  end

  def vehicle_count_bidable
    return unless opportunity
    return if opportunity.vehicle_count == 1

    if vehicle_count > opportunity.vehicle_count
      errors.add :vehicle_count, "cannot be greater than vehicle count of opportunity."
    end
  end

  def vehicle_count_limit_bidable
    return unless opportunity
    return if opportunity.vehicle_count == 1
    return if vehicle_count_limit.blank?

    if vehicle_count_limit > vehicle_count
      errors.add :vehicle_count_limit, "cannot be greater than vehicle count you are bidding."
    end
  end

  # Forward auction
  # first  500, 800 => 701
  # second 600, 700 => 700
  # third  620, 650 => 650
  #
  # Reverse auction
  # first  800, 500 => 599
  # second 700, 600 => 600
  # third  650, 620 => 620
  def run_automatic_bidding
    return unless opportunity.bids.active.size > 1

    leading_bid_amount = opportunity.leading_bid_amount
    opportunity.bids.active.select { |b| b.auto_bidding_limit.present? }.each do |bid|
      if opportunity.forward_auction
        if bid.amount < leading_bid_amount and bid.amount < bid.auto_bidding_limit
          new_amount = bid.auto_bidding_limit
          bid.update_attribute(:amount, new_amount)
        end
      else
        if bid.amount > leading_bid_amount and bid.amount > bid.auto_bidding_limit
          new_amount = bid.auto_bidding_limit
          bid.update_attribute(:amount, bid.auto_bidding_limit)
        end
      end
    end
  end
end
