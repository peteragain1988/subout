FactoryGirl.define do
  sequence(:subscription_id) { |n| "sub_id_#{n}" }

  factory :gateway_subscription do
    product_handle "subout-national-service"
    subscription_id

    factory :state_by_state_subscription do
      product_handle "state-by-state-service"

      after(:create) do |subscription|
        subscription.update_attribute(:regions, ["California", "New York"])
      end
    end
  end
end
