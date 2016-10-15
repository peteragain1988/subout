require 'rubygems'
require 'httparty'
require 'pp'

class MyChargify
  include HTTParty
  base_uri 'subout.chargify.com'
  basic_auth 'FsikQqr_iR0tcokkv8db', 'x'

  def subscriptions
    self.class.get("/subscriptions.json")
  end

  def get_subscription(subscription_id)
    self.class.get("/subscriptions/#{subscription_id}.json")
  end
  def get_components(subscription_id)
    self.class.get("/subscriptions/#{subscription_id}/components.json")
  end
end

chargify = MyChargify.new
subscriptions = chargify.subscriptions
subscriptions.each do |s|
  puts chargify.get_components(s["subscription"]["id"]).to_yaml
end
