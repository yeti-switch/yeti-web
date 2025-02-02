# frozen_string_literal: true

module AggChart
  extend ActiveSupport::Concern

  included do
    class_attribute :chart_entity_column, instance_accessor: false
  end

  module ClassMethods
    def to_chart(id, options = {})
      count_column = options.delete(:count_column) || :count
      res = {
        max: [],
        min: [],
        avg: []
      }
      where(chart_entity_column => id)
        .where('created_at > ? AND created_at < NOW() ', 1.week.ago)
        .order('calls_time')
        .pluck(:calls_time, :"max_#{count_column}", :"min_#{count_column}", :"avg_#{count_column}")
        .map do |d|
        x = d[0].to_datetime.to_fs(:db)
        res[:max] << { x: x, y: d[1] }
        res[:min] << { x: x, y: d[2] }
        res[:avg] << { x: x, y: d[3] }
      end
      res.map do |k, v|
        {
          values: v,
          key: k
        }
      end
    end
  end
end
