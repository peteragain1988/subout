class Setting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key
  field :value

  Setting::KEYS = ["admin_email", "application_message", "marketing_message", "promotion_message", "sender_email"]
  
  validates_presence_of :value
  validates_uniqueness_of :key
  validate :validate_key
  validate :validate_santinized_length, if: :application_message? 

  def to_param
    key
  end

  def to_s
    key.gsub("_", " ").capitalize
  end

  def label
    key.split('_').last.capitalize
  end

  def self.get(key)
    Setting.where(key: key).first.try(:value)
  end

  def self.admin_email
    Setting.find_by(key: 'admin_email').value
  end

  def application_message?
    self.key == "application_message"
  end

  def validate_key
    Setting::KEYS.include?(key)
  end

  def validate_santinized_length
    return unless value

    striped_value = HTML::FullSanitizer.new.sanitize(value)
    if striped_value.length > 2000
      errors.add(:santinized_length, "cannot be greater than 2000")
    end
  end
end
