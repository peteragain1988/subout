require 'rubygems'
require 'httparty'

class MyChargify
  include HTTParty
  base_uri CHARGIFY_URI
  basic_auth CHARGIFY_TOKEN, 'x'

  def self.get_subscription(subscription_id)
    self.get("/subscriptions/#{subscription_id}.json")
  end

  def self.get_components(subscription_id)
    self.get("/subscriptions/#{subscription_id}/components.json")
  end

  def self.self_service_url(subscription_id)
    return nil unless subscription_id.present?

    token = Digest::SHA1.hexdigest("update_payment--#{subscription_id}--#{ENV["CHARGIFY_HOSTED_PAGE_TOKEN"]}")[0..9]
    "https://#{CHARGIFY_URI}/update_payment/#{subscription_id}/#{token}"
  end
end

#chargify = MyChargify.new
#sub = chargify.get_subscription(2559906)

#PP.pp(sub["subscription"], $>, 40)

#component = chargify.get_components(2559906)

#PP.pp(component, $>, 40)
