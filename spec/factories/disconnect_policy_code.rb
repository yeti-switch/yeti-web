# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_policy_code
#
#  id                        :integer          not null, primary key
#  policy_id                 :integer          not null
#  code_id                   :integer          not null
#  stop_hunting              :boolean          default(TRUE), not null
#  pass_reason_to_originator :boolean          default(FALSE), not null
#  rewrited_code             :integer
#  rewrited_reason           :string
#

FactoryBot.define do
  factory :disconnect_policy_code, class: DisconnectPolicyCode do
    policy { DisconnectPolicy.take || create(:disconnect_policy) }
    code { DisconnectCode.take || create(:disconnect_code, namespace_id: DisconnectCode::NS_SIP) }
  end
end
