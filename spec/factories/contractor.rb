FactoryGirl.define do
  factory :contractor, class: Contractor do
    name nil
    enabled true
    vendor false
    customer false
  end
end
