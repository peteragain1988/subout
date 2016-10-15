class OfferShortSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :_id, :amount, :formatted_amount
  has_one :vendor

  def formatted_amount
    number_to_currency(object.amount, :unit=>'')
  end
end
