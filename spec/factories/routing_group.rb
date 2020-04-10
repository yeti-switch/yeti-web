# frozen_string_literal: true

FactoryGirl.define do
  factory :routing_group, class: RoutingGroup do
    sequence(:name) { |n| "routing_group_#{n}" }

    trait :with_dialpeers do
      dialpeers { build_list :dialpeer, 2 }
    end
  end
end
