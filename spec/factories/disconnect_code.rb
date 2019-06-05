# frozen_string_literal: true

FactoryGirl.define do
  factory :disconnect_code, class: DisconnectCode do
    sequence(:code, 100) { |n| n }
    sequence(:reason, 100) { |n| "reason_#{n}" }

    trait :tm do
      namespace_id DisconnectCode::NS_TM
    end

    trait :ts do
      namespace_id DisconnectCode::NS_TS
    end

    trait :sip do
      namespace_id DisconnectCode::NS_SIP
    end

    trait :radius do
      namespace_id DisconnectCode::NS_RADIUS
    end
  end
end
