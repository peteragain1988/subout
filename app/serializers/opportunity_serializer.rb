class OpportunitySerializer < ActiveModel::Serializer
  attributes :_id, :name, :description, :start_date, :start_time, :for_favorites_only, :start_region, :end_region,
    :end_date, :end_time, :bidding_duration_hrs, :bidding_ends_at, :bidding_done, :quick_winnable, :bidable?, :image_id,
    :winning_bid_id, :win_it_now_price, :type, :vehicle_type, :trip_type, :canceled, :in_negotiation, :forward_auction, :winner, :tracking_id, :reference_number,
    :buyer_name, :buyer_abbreviated_name, :buyer_message, :image_url, :large_image_url, :start_location, :end_location, :created_at, :status, :buyer_id, :contact_phone,
    :highest_bid_amount, :lowest_bid_amount, :reserve_amount, :ada_required, :start_date, :icon, :vehicle_count, :special_region, :is_for_special_region, :value, :for_quote_only

  
  has_one :buyer, serializer: ActorSerializer
  has_many :recent_bids, serializer: BidShortSerializer, :key=>"bids"
  has_many :comments, serializer: CommentSerializer
  has_one :quote_request
  has_one :offer, serializer: OfferShortSerializer

  def icon
    "icon-#{object.type.parameterize}" if object.type
  end

  def reference_number
    return object.quote_request.reference_number if object.quote_request
    object.reference_number
  end

  def winner
    return unless object.winning_bid

    winning_bid = object.winning_bid
    {name: winning_bid.bidder.name, amount: winning_bid.amount, vehicle_count: winning_bid.vehicle_count}
  end

  def image_url
    Cloudinary::Utils.cloudinary_url(object.image_id, width: 200, crop: :scale, format: 'png')
  end

  def large_image_url
    Cloudinary::Utils.cloudinary_url(object.image_id, width: 500, crop: :scale, format: 'png')
  end

  def buyer_name
    object.buyer.try(:name)
  end

  def buyer_abbreviated_name
    object.buyer.try(:abbreviated_name)
  end

  def buyer_message
    object.buyer.try(:poster_message)
  end

  def start_date
    object.start_date.strftime("%Y/%m/%d") if object.start_date
  end

  def end_date
    object.end_date.strftime("%Y/%m/%d") if object.end_date
  end

  def win_it_now_price
    return nil unless object.win_it_now_price.present?

    object.win_it_now_price.to_i
  end

  def bidding_ends_at
    object.bidding_ends_at.getutc.iso8601
  end
end
