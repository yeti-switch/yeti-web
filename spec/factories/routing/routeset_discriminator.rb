# frozen_string_literal: true

FactoryGirl.define do
  factory :routeset_discriminator, class: Routing::RoutesetDiscriminator do
    sequence(:name) { |n| "Discriminator #{n}" }
  end
end
