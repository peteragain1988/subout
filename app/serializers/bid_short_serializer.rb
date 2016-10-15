class BidShortSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :_id, :amount, :formatted_amount, :created_at, :comment, :vehicle_count, :state, :offer_amount, :counter_amount

  has_many :vehicles
  has_one :bidder, serializer: ActorSerializer

  def formatted_amount
    number_to_currency(object.amount, :unit=>'')
  end

  def comment
    object.comment_as_seen_by(object.opportunity.viewer)
  end
end
