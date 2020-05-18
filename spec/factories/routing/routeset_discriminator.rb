# frozen_string_literal: true

FactoryBot.define do
  factory :routeset_discriminator, class: Routing::RoutesetDiscriminator do
    sequence(:name) { |n| "Discriminator #{n}" }
  end
end
