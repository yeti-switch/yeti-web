# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_tags
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routing_tags_name_key  (name) UNIQUE
#
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
