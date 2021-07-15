# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_code
#
#  id                        :integer(4)       not null, primary key
#  code                      :integer(4)       not null
#  pass_reason_to_originator :boolean          default(FALSE), not null
#  reason                    :string           not null
#  rewrited_code             :integer(4)
#  rewrited_reason           :string
#  silently_drop             :boolean          default(FALSE), not null
#  stop_hunting              :boolean          default(TRUE), not null
#  store_cdr                 :boolean          default(TRUE), not null
#  success                   :boolean          default(FALSE), not null
#  successnozerolen          :boolean          default(FALSE), not null
#  namespace_id              :integer(4)       not null
#
# Indexes
#
#  disconnect_code_code_success_successnozerolen_idx  (code,success,successnozerolen)
#
# Foreign Keys
#
#  disconnect_code_namespace_id_fkey  (namespace_id => disconnect_code_namespace.id)
#

FactoryBot.define do
  factory :disconnect_code, class: DisconnectCode do
    id { (DisconnectCode.pick(Arel.sql('MAX(id)')) || 0) + 1 } # broken sequence in class4.sql
    sequence(:code, 100) { |n| n }
    sequence(:reason, 100) { |n| "reason_#{n}" }

    trait :tm do
      namespace_id { DisconnectCode::NS_TM }
    end

    trait :ts do
      namespace_id { DisconnectCode::NS_TS }
    end

    trait :sip do
      namespace_id { DisconnectCode::NS_SIP }
    end

    trait :radius do
      namespace_id { DisconnectCode::NS_RADIUS }
    end
  end
end
