class EmailTemplate
  include Mongoid::Document
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper

  CATEGORIES = %w(normal consumer vendor)
  field :name
  field :subject
  field :body
  field :description
  field :category

  validates_presence_of :name, :subject, :body

  before_validation :exchange_double_quote

  def self.by_name(name)
    self.where(name: name).first
  end

  def to_s
    name.gsub("_", " ").capitalize
  end

  def subject_to_string
    prepare_binding_variables()
    eval('"' + self.subject + '"', binding)
  rescue
    "Syntax error"
  end

  def body_to_html
    prepare_binding_variables()
    eval('"' + self.body_with_signature + '"', binding)
  rescue
    "Syntax error"
  end

  def body_with_signature
    "#{self.body} <p>Sincerely,</p><p>The SubOut Team</p>"
  end

  def prepare_binding_variables
    @bid = Bid.last
    @bidder = @bid.bidder
    @opportunity = @bid.opportunity
    @poster = @opportunity.buyer
    @subscription = GatewaySubscription.last
    @company = Company.last
    @vehicle = Vehicle.last
    @old_vehicle = Vehicle.first
    @card_update_link = @company.chargify_service_url
    @quote = Quote.last
    @quoter = @quote.quoter
    @quote_request = @quote.quote_request
    @vendor = Vendor.last
    @offer = Offer.last
    @supplier = @offer.opportunity.buyer
    @new_opportunity = @offer.opportunity
  end

  def exchange_double_quote
    self.subject = self.subject.gsub('"', "'")
    self.body = self.body.gsub('"', "'")
  end
end
