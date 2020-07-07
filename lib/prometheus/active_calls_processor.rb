# frozen_string_literal: true

class ActiveCallsProcessor
  class_attribute :logger, instance_writer: false, default: Rails.logger
  class_attribute :type, instance_writer: false, default: 'yeti_ac'

  def self.collect(data, labels = {})
    new(labels).collect(data)
  end

  def initialize(labels = {})
    @metric_labels = labels || {}
  end

  def collect(data)
    format_metric(data)
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
