class QuoteSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :_id, :amount, :formatted_amount, :created_at, :comment, :vehicle_count, :state

  has_many :vehicles
  has_one :quoter, serializer: ActorSerializer, key: :bidder

  def formatted_amount
    number_to_currency(object.amount, :unit=>'')
  end

  def comment
    object.comment_as_seen_by(object.quote_request.viewer)
  end
end
