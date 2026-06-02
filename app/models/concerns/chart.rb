# frozen_string_literal: true

module Chart
  extend ActiveSupport::Concern

  included do
    class_attribute :chart_entity_column, instance_accessor: false
    class_attribute :chart_entity_klass, instance_accessor: false

    scope :hours_ago, lambda { |hours|
      where('created_at > ? AND created_at < NOW() ', hours.hours.ago).order('created_at')
    }
  end

  class_methods do
    def to_chart(id, options = {})
      hours = options.delete(:hours) || 24
      time_column = options.delete(:time_column) || :created_at
      count_column = options.delete(:count_column) || :count
      values = where(chart_entity_column => id).hours_ago(hours).pluck(time_column, count_column)
      values_formatted = values.map { |val| { x: val.first.to_i * 1000, y: val.second } }
      line = {
        key: chart_entity_klass.find(id).name,
        area: true,
        values: values_formatted
      }.merge(options)
      [line]
    end
  end
end
