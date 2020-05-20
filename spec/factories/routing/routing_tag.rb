# frozen_string_literal: true

FactoryBot.define do
  factory :routing_tag, class: Routing::RoutingTag do
    sequence(:name) { |n| "TAG_#{n}" }

    initialize_with { Routing::RoutingTag.find_or_create_by(name: name) }

    trait :ua do
      name { 'UA_CLI' }
    end

    trait :emergency do
      name { 'Emergency' }
    end

    trait :us do
      name { 'US_CLI' }
    end
  end
end
