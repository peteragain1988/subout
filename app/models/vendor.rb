class Vendor
  include Mongoid::Document

  field :name,            :type => String
  field :email,           :type => String
  field :address,         :type => String
  field :city,            :type => String
  field :state,           :type => String

  field :crm_vendor_id,   :type => String
  field :source,     :type => Boolean

  has_many :offers

  validates_presence_of :email
  validates_uniqueness_of :email

  before_save do
    self.email.downcase! if self.email
  end

  def self.find_by_email(email)
    where(:email => email).first
  end

  def total_invited_amount
    self.offers.active.sum(&:amount)
  end

  def total_won_amount
    self.offers.accepted.sum(&:amount)
  end

  def to_html
<<-EOS
    <p><strong>Name:</strong> #{self.name}</p>
    <p><strong>Email:</strong> #{self.email}</p>
    <p><strong>Address:</strong> #{self.address}</p>
EOS
  end

  def self.update_from_athana
    vendors = Athana.get_vendors

    vendors.each do |vendor|
      v = Vendor.where(email: vendor[:vendor_email].downcase).first
      c = Company.where(email: vendor[:vendor_email].downcase).first
      s = c.blank? ? 'athana': 'subout'

      if v.nil?
        Vendor.create(
          name: vendor[:vendor_name],
          email: vendor[:vendor_email].downcase,
          city: vendor[:vendor_city],
          state: vendor[:vendor_state],
          crm_vendor_id: vendor[:vendor_id],
          source: s
        )
      else
        v.update_attributes(
          name: vendor[:vendor_name],
          city: vendor[:vendor_city],
          state: vendor[:vendor_state],
          crm_vendor_id: vendor[:vendor_id],
          source: s
        )
      end
    end
  end
end
