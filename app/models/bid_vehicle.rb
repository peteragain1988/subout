class BidVehicle
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :bid, inverse_of: :vehicles
  embedded_in :quote, inverse_of: :vehicles

  field :year, type: Integer
  field :type, type: String
  field :type_other, type: String
  field :passenger_count, type: Integer
  field :gratuity_included, type: Boolean, default: 0

  validates_presence_of :year
  validates_presence_of :passenger_count
  validate :validate_type

  def validate_type
    errors.add(:type, "couldn't be blank.") if self.type.blank? and self.type_other.blank?
  end

  def to_html
    ["<strong>Year:</strong> #{year}",
    "<strong>Type:</strong> #{type || type_other}",
    "<strong>Passengers:</strong> #{passenger_count}",
    "<strong>Gratuity included?:</strong> #{gratuity_included}"].join('<br/>')
  end
end
