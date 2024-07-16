# frozen_string_literal: true

FactoryBot.define do
  factory :incoming_registration, class: 'RealtimeData::IncomingRegistration' do
    trait :filled do
      auth_id { 123 }
      contact { 'sip:test@10.255.10.2' }
      expires { '3600' }
      sequence(:path) { |n| "sip:test.#{n}@domain" }
      user_agent { 'Twinkle' }
    end

    trait :with_gateway do
      gateway
    end
  end
end
