FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "person#{n}@example.com" }
    password "password1"
    password_confirmation "password1"
    company
  end
end
