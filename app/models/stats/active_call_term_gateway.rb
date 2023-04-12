# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_term_gateways
#
#  id         :bigint(8)        not null, primary key
#  count      :integer(4)       not null
#  created_at :timestamptz
#  gateway_id :integer(4)       not null
#

class Stats::ActiveCallTermGateway < Stats::Base
  self.table_name = 'stats.active_call_term_gateways'
  belongs_to :gateway, optional: true

  include ::Chart
  self.chart_entity_column = :gateway_id
  self.chart_entity_klass = Gateway
end
