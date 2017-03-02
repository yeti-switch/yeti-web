FactoryGirl.define do
  factory :importing_contractor, class: Importing::Contractor do
    o_id nil
    name nil
    enabled true
    vendor false
    customer false
    error_string nil
  end
end
