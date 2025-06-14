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

class DisconnectPolicyCode < ApplicationRecord
  self.table_name = 'disconnect_policy_code'

  include WithPaperTrail

  belongs_to :policy, class_name: 'DisconnectPolicy', foreign_key: :policy_id
  belongs_to :code, class_name: 'DisconnectCode', foreign_key: :code_id

  validates :policy_id, :code_id, presence: true

  def display_name
    id.to_s
  end

  include Yeti::TranslationReloader
  include Yeti::StateUpdater
  self.state_names = ['translations']
end
