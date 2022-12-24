# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr_exports
#
#  id                  :integer(4)       not null, primary key
#  callback_url        :string
#  fields              :string           default([]), not null, is an Array
#  filters             :json             not null
#  rows_count          :integer(4)
#  status              :string           not null
#  type                :string           not null
#  uuid                :uuid             not null
#  created_at          :datetime
#  updated_at          :datetime
#  customer_account_id :integer(4)
#
# Indexes
#
#  index_sys.cdr_exports_on_customer_account_id  (customer_account_id)
#  index_sys.cdr_exports_on_uuid                 (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_e796f29195  (customer_account_id => accounts.id)
#

class CdrExport::Base < ::CdrExport
  def self.policy_class
    CdrExportPolicy
  end
end
