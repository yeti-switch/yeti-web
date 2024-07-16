# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_policy_code
#
#  id                        :integer(4)       not null, primary key
#  pass_reason_to_originator :boolean          default(FALSE), not null
#  rewrited_code             :integer(4)
#  rewrited_reason           :string
#  stop_hunting              :boolean          default(TRUE), not null
#  code_id                   :integer(4)       not null
#  policy_id                 :integer(4)       not null
#
# Foreign Keys
#
#  disconnect_code_policy_codes_code_id_fkey    (code_id => disconnect_code.id)
#  disconnect_code_policy_codes_policy_id_fkey  (policy_id => disconnect_policy.id)
#

FactoryBot.define do
  factory :disconnect_policy_code, class: 'DisconnectPolicyCode' do
    policy { DisconnectPolicy.take || create(:disconnect_policy) }
    code { DisconnectCode.take! }
  end
end
