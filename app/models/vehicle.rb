class Vehicle
  include Mongoid::Document
  include Mongoid::Timestamps

  # attr_protected :company_id, :editable

  field :year, type: Integer
  field :make, type: String
  field :model, type: String
  field :vin, type: String
  field :rm_number, type: String

  belongs_to :company

  validates_presence_of :year
  validates_presence_of :make
  validates_presence_of :model
  validates_presence_of :vin
end
