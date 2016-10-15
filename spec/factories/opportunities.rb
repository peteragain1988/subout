FactoryGirl.define do
  factory :opportunity, aliases: [:auction] do
    association :buyer, factory: :company
    name "Opportunity Name"
    description "80 seats"
    start_location "77 Barnhill Rd, West Barnstable, MA 02668"
    end_location "11 Old Toll Rd, West Barnstable, MA 02668"
    start_date { 1.month.from_now }
    end_date { 2.months.from_now}
    start_time "00:00"
    end_time "00:00"
    bidding_duration_hrs 24
    quick_winnable false
    type 'Vehicle Needed'

    factory :quick_winnable_auction do
      quick_winnable true
      win_it_now_price "200.0"
    end

    factory :forward_auction do
      forward_auction true
    end
  end
end
