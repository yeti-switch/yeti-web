# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_calls
# Database name: cdr
#
#  id         :bigint(8)        not null, primary key
#  count      :integer(4)       not null
#  created_at :timestamptz
#  node_id    :integer(4)       not null
#

class Stats::ActiveCall < Stats::Base
  self.table_name = 'stats.active_calls'
  belongs_to :node, optional: true

  include ::Chart
  self.chart_entity_column = :node_id
  self.chart_entity_klass = Node

  # Stats::ActiveCall.where('created_at > ?', 1.day.ago).to_chart
  def self.to_stacked_chart(hours_ago = 24)
    nodes = Node.order(:name).pluck(:id, :name).to_h
    # EXTRACT EPOCH in SQL: avoid building TimeWithZone per row (~5 allocs
    # each) — saves tens of thousands of allocations for 24h × multi-node.
    rows = self.hours_ago(hours_ago).where(node_id: nodes.keys)
               .pluck(
                 Arel.sql('(EXTRACT(EPOCH FROM created_at) * 1000)::bigint'),
                 :count,
                 :node_id
               )

    rows.group_by { |r| nodes[r.last] }.map do |name, group|
      {
        key: name,
        values: group.map { |el| { x: el[0], y: el[1] } }
      }
    end
  end
end
