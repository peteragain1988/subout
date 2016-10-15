class OpportunityShortSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :icon, :type, :for_favorites_only,
    :quick_winnable, :bidable?, :buyer_id, :start_region, :end_region, :vehicle_type, :trip_type,
    :buyer_name, :buyer_abbreviated_name, :reference_number, :canceled, :in_negotiation, :win_it_now_price, :status,
    :bidding_ends_at, :ada_required, :start_date, :end_date, :reserve_amount, :forward_auction, :vehicle_count, 
    :special_region, :is_for_special_region, :for_quote_only

  has_one :buyer, serializer: ActorSerializer
  has_one :offer, serializer: OfferShortSerializer
  
  def icon
    "icon-#{object.type.parameterize}" if !object.for_quote_only
  end

  def reference_number
    return object.quote_request.reference_number if object.quote_request
    object.reference_number
  end

  def buyer_name
    object.buyer.try(:name)
  end

  def buyer_abbreviated_name
    object.buyer.try(:abbreviated_name)
  end

  def start_date
    object.start_date.strftime("%Y/%m/%d") if object.start_date
  end

  def end_date
    object.end_date.strftime("%Y/%m/%d") if object.end_date
  end
end
