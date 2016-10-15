require 'securerandom'

class FavoriteInvitation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :supplier_name, type: String
  field :supplier_email, type: String
  field :message, type: String
  field :accepted, type: Boolean, default: false

  scope :pending, -> { where(accepted: false) }
  scope :recent, -> { desc(:created_at) }

  belongs_to :buyer, :class_name => "Company"

  has_one :created_company, :class_name => "Company"

  def accept!
    buyer.add_favorite_supplier!(created_company)
    self.update_attribute(:accepted, true)
  end

  def pending?
    !accepted
  end
end
