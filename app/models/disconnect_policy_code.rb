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

class DisconnectPolicyCode < ActiveRecord::Base
  self.table_name = 'disconnect_policy_code'

  belongs_to :policy, class_name: 'DisconnectPolicy', foreign_key: :policy_id
  belongs_to :code, -> { where namespace_id: DisconnectCode::NS_SIP }, class_name: 'DisconnectCode', foreign_key: :code_id

  has_paper_trail class_name: 'AuditLogItem'

  validates_presence_of :policy_id, :code_id

  def display_name
    id.to_s
  end

  include Yeti::TranslationReloader
end
