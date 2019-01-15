# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_calls
#
#  id         :integer          not null, primary key
#  node_id    :integer          not null
#  count      :integer          not null
#  created_at :datetime
#

class Stats::ActiveCall < Stats::Base
  self.table_name = 'stats.active_calls'
  belongs_to :node

  include ::Chart
  self.chart_entity_column = :node_id
  self.chart_entity_klass = Node

  # Stats::ActiveCall.where('created_at > ?', 1.day.ago).to_chart
  def self.to_stacked_chart(hours_ago = 24)
    nodes = Node.order(:name).pluck(:id, :name).to_h
    self.hours_ago(hours_ago).where(node_id: nodes.keys).pluck(:created_at, :count, :node_id)
        .group_by do |n|
      nodes[n.last]
    end
        .map do |key_value_pair|
      {
        key: key_value_pair[0],
        # change to x,y
        values: key_value_pair[1].map do |el|
                  [el[0].to_datetime.to_s(:db), el[1]]
                end
      }
    end
  end
end
