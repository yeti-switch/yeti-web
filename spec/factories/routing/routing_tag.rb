FactoryGirl.define do
  factory :routing_tag, class: Routing::RoutingTag do
    sequence(:name) { |n| "TAG_#{n}" }
  end
end
