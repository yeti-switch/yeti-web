# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_accounts_hourly
#
#  id                   :bigint(8)        not null, primary key
#  avg_originated_count :integer(4)       not null
#  avg_terminated_count :integer(4)       not null
#  calls_time           :datetime         not null
#  max_originated_count :integer(4)       not null
#  max_terminated_count :integer(4)       not null
#  min_originated_count :integer(4)       not null
#  min_terminated_count :integer(4)       not null
#  created_at           :datetime         not null
#  account_id           :integer(4)       not null
#

class Stats::AggActiveCallAccount < Stats::Base
  self.table_name = 'stats.active_call_accounts_hourly'

  include ::AggChart
  self.chart_entity_column = :account_id

  class << self
    def to_chart_customer(account_id, options = {})
      options = options.merge(count_column: :originated_count)
      to_chart(account_id, options)
    end

    def to_chart_vendor(account_id, options = {})
      options = options.merge(count_column: :terminated_count)
      to_chart(account_id, options)
    end
  end
end
