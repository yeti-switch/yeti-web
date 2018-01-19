FactoryGirl.define do
  factory :area, class: Routing::Area do
    sequence(:name) { |n| "Routing_Area_#{n}" }
  end
end
