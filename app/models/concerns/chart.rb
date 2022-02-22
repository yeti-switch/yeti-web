# frozen_string_literal: true

module Chart
  extend ActiveSupport::Concern

  included do
    class_attribute :chart_entity_column, instance_accessor: false
    class_attribute :chart_entity_klass, instance_accessor: false

    scope :day_ago, -> { hours_ago(24) }
    scope :hours_ago, lambda { |hours|
      where('created_at > ? AND created_at < NOW() ', hours.hours.ago).order('created_at')
    }
  end

  class_methods do
    def to_chart(id, options = {})
      time_column = options.delete(:time_column) || :created_at
      count_column = options.delete(:count_column) || :count
      values = where(chart_entity_column => id).day_ago.pluck(time_column, count_column)
      values_formatted = values.map { |val| { x: val.first.to_datetime.to_s(:db), y: val.second } }
      line = {
        key: chart_entity_klass.find(id).name,
        area: true,
        values: values_formatted
      }.merge(options)
      [line]
    end
  end
end
