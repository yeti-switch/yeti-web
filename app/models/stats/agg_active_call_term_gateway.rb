# == Schema Information
#
# Table name: stats.active_call_term_gateways_hourly
#
#  id         :integer          not null, primary key
#  gateway_id :integer          not null
#  max_count  :integer          not null
#  avg_count  :float            not null
#  min_count  :integer          not null
#  created_at :datetime         not null
#  calls_time :datetime         not null
#

class Stats::AggActiveCallTermGateway < Stats::Base
  self.table_name = "stats.active_call_term_gateways_hourly"
  include ::AggChart
   self.chart_entity_column = :gateway_id
end
