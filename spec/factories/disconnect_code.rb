# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_code
#
#  id                        :integer          not null, primary key
#  namespace_id              :integer          not null
#  stop_hunting              :boolean          default(TRUE), not null
#  pass_reason_to_originator :boolean          default(FALSE), not null
#  code                      :integer          not null
#  reason                    :string           not null
#  rewrited_code             :integer
#  rewrited_reason           :string
#  success                   :boolean          default(FALSE), not null
#  successnozerolen          :boolean          default(FALSE), not null
#  store_cdr                 :boolean          default(TRUE), not null
#  silently_drop             :boolean          default(FALSE), not null
#

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
