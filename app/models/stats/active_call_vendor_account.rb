# == Schema Information
#
# Table name: stats.active_call_vendor_accounts
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  count      :integer          not null
#  created_at :datetime
#

class Stats::ActiveCallVendorAccount < Stats::Base
  self.table_name = "stats.active_call_vendor_accounts"
  belongs_to :account


  include ::Chart
  self.chart_entity_column = :account_id
  self.chart_entity_klass = Account
end
