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

class DisconnectCode < ActiveRecord::Base
  self.table_name = 'disconnect_code'
  belongs_to :namespace, class_name: 'DisconnectCodeNamespace', foreign_key: 'namespace_id'

  def display_name
    "#{namespace_id}.#{code} - #{reason}"
  end

  has_paper_trail class_name: 'AuditLogItem'

  include Yeti::TranslationReloader

  NS_TM  = 0
  NS_TS  = 1
  NS_SIP = 2
  NS_RADIUS = 3
end
