# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_accounts_hourly
#
#  id                   :integer          not null, primary key
#  account_id           :integer          not null
#  max_originated_count :integer          not null
#  avg_originated_count :integer          not null
#  min_originated_count :integer          not null
#  max_terminated_count :integer          not null
#  avg_terminated_count :integer          not null
#  min_terminated_count :integer          not null
#  created_at           :datetime         not null
#  calls_time           :datetime         not null
#

class Stats::AggActiveCallAccount < Stats::Base
  self.table_name = 'stats.active_call_accounts_hourly'

  include ::AggChart
  self.chart_entity_column = :account_id

  class << self
    def to_chart_customer(account_id, options = {})
      options = options.merge(count_column: :terminated_count)
      to_chart(account_id, options)
    end

    def to_chart_vendor(account_id, options = {})
      options = options.merge(count_column: :originated_count)
      to_chart(account_id, options)
    end
  end
end
