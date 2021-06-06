# frozen_string_literal: true

class BaseProcessor
  class_attribute :logger, instance_writer: false
  class_attribute :type, instance_writer: false

  def self.collect(data, labels = {})
    new(labels).collect(data)
  end

  def initialize(labels = {})
    @metric_labels = labels || {}
  end

  private

  def format_metric(data)
    labels = (data.delete(:labels) || {}).merge(@metric_labels)
    {
      type: type,
      metric_labels: labels,
      **data
    }
  end
end
