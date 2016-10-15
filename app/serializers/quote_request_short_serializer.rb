class QuoteRequestShortSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :vehicle_count, :vehicle_type, :trip_type, :reference_number, :start_date, :start_region, :end_region, :description,
    :bidding_ends_at, :quotable, :for_quote_only, :status, :start_location, :end_location
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
end
