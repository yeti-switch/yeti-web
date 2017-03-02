# == Schema Information
#
# Table name: stats.active_call_customer_accounts
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  count      :integer          not null
#  created_at :datetime
#

class Stats::ActiveCallCustomerAccount < Stats::Base
  self.table_name = "stats.active_call_customer_accounts"
  belongs_to :account


  include ::Chart
  self.chart_entity_column = :account_id
  self.chart_entity_klass = Account




end
