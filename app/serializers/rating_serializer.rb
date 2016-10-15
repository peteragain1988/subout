class RatingSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :_id, :score, :editable, :communication, :punctuality, :ease_of_payment, :over_all_experience,
    :like_again, :trip_expected

  has_one :rater, serializer: CompanyShortSerializer
  has_one :ratee, serializer: CompanyShortSerializer
end
