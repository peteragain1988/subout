class MobileKey
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :key
  field :device_type #iOS, Android

  scope :ios, -> { where(device_type: 'iOS') }
  scope :android, -> { where(device_type: 'Android') }

  after_create :register_token_into_urbanairship

  def self.push_message_to_android(keys, message) 
    notification = {
      apids: keys,
      android: message 
    }

    resp = Urbanairship.push(notification)
  end

  def self.push_message_to_ios(keys, message) 
    notification = {
      device_tokens: keys,
      aps: message 
    }

    resp = Urbanairship.push(notification)
  end

  def register_token_into_urbanairship
    if device_type == 'iOS'
      Urbanairship.register_device(self.key)
    else
      Urbanairship.register_device(self.key, provider: :android)
    end
  end
end
