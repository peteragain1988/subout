FactoryGirl.define do
  factory :favorite_invitation do
    association :buyer, factory: :company
    supplier_name 'Boston Bus'
    supplier_email 'thomas@bostonbus.com'
  end
end
