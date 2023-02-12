# frozen_string_literal: true

FactoryBot.define do
  factory :dialpeer_next_rate do
    initial_rate     { 0 }
    next_rate        { 0 }
    initial_interval { 5 }
    next_interval    { 10 }
    connect_fee      { 0 }
    apply_time       { 1.hour.from_now }
    applied          { false }

    association :dialpeer

    trait :random do
      initial_rate { 0.04 + rand.round(2) }
      next_rate { 0.05 + rand.round(2) }
      initial_interval { rand(90..149) }
      next_interval { rand(120..179) }
      connect_fee { 0.06 + rand.round(2) }
    end
  end
end
