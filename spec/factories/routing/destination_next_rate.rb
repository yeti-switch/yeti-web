# frozen_string_literal: true

FactoryBot.define do
  factory :destination_next_rate, class: Routing::DestinationNextRate do
    initial_rate { 0 }
    next_rate { 0 }
    initial_interval { 5 }
    next_interval { 10 }
    connect_fee { 0 }
    apply_time { 1.hour.from_now }
    applied { false }

    association :destination

    trait :random do
      initial_rate { 0.04 + rand.round(2) }
      next_rate { 0.05 + rand.round(2) }
      connect_fee { 0.06 + rand.round(2) }
      initial_interval { rand(90..149) }
      next_interval { rand(120..179) }
    end
  end
end
