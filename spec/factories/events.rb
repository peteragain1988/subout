FactoryGirl.define do
  factory :event do
    association :eventable, factory: :opportunity
    association :actor, factory: :company
  end
end
