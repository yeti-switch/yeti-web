# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_vendor_accounts_hourly
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  max_count  :integer          not null
#  avg_count  :float            not null
#  min_count  :integer          not null
#  created_at :datetime         not null
#  calls_time :datetime         not null
#

class Stats::AggActiveCallVendorAccount < Stats::Base
  self.table_name = 'stats.active_call_vendor_accounts_hourly'

  include ::AggChart
  self.chart_entity_column = :account_id
end
