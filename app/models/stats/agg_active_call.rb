# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_calls_hourly
#
#  id         :bigint(8)        not null, primary key
#  avg_count  :float(24)        not null
#  calls_time :timestamptz      not null
#  max_count  :integer(4)       not null
#  min_count  :integer(4)       not null
#  created_at :timestamptz      not null
#  node_id    :integer(4)       not null
#

class Stats::AggActiveCall < Stats::Base
  self.table_name = 'stats.active_calls_hourly'

  include ::AggChart
  self.chart_entity_column = :node_id
end
