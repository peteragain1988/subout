FactoryGirl.define do
  factory :bid do
    association :bidder, :factory => :supplier
    opportunity
    amount "10.0"
  end
end
