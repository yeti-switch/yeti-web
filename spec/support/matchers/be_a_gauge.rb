# frozen_string_literal: true

RSpec::Matchers.define :be_a_gauge do |name|
  description do
    "be a gauge name=#{metric_name} with=#{@with}"
  end

  define_method(:metric_name) { name.to_s }

  match do |actual_metric|
    unless actual_metric.is_a?(PrometheusExporter::Metric::Gauge)
      # @class_invalid = true
      return false
    end

    if actual_metric.name.to_s != name.to_s
      # @name_invalid = true
      return false
    end

    if @with
      expected = @with.map { |labels, value| [labels.stringify_keys.transform_values(&:to_s), value] }
      actual = actual_metric.data.map { |labels, value| [labels.stringify_keys.transform_values(&:to_s), value] }
      return values_match?(match_array(expected), actual)
    end

    true
  end

  chain :with do |value, labels = {}|
    @with ||= {}
    @with[labels] = value
  end
end
