class QuoteRequestSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :email, :vehicle_count, :vehicle_type, :trip_type, :reference_number, :start_date, :start_time,  :start_region, :end_region, :description,
    :bidding_ends_at, :quotable, :for_quote_only, :status, :start_location, :end_location, :departure_date, :departure_time

  has_many :recent_quotes, array_seralizer: QuoteShortSerializer

  def name
    "#{object.first_name} #{object.last_name}"
  end

  def bidding_ends_at
    object.created_at + 48.hours
  end

  def quotable
    object.quotable?
  end

  def for_quote_only
    true
  end

  def start_date
    object.start_date.strftime("%Y/%m/%d") if object.start_date
  end

  def departure_date
    object.departure_date.strftime("%Y/%m/%d") if object.departure_date
  end
end
