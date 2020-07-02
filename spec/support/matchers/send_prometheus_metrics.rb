# frozen_string_literal: true

# Matcher that checks metrics that being sent to prometheus exporter.
# In test environment we replace default prometheus client with RSpecTestPrometheusClient.
# Don't forget to add `before { allow(PrometheusConfig).to receive(:enabled?).and_return(true) }`
# to enable prometheus for context.
#
# @example
#
# expect { subject }.to send_prometheus_metrics
# # check that at least 1 metric of any type was sent.
#
# expect { subject }.to send_prometheus_metrics('yeti_ac')
# # check that at least 1 metric of type 'yeti_ac' was sent.
#
# expect { subject }.to send_prometheus_metrics.exactly(5)
# # check that exactly 5 metrics of any type with any payload were sent.
#
# expect { subject }.to send_prometheus_metrics('yeti_ac').exactly(5)
# # check that exactly 5 metrics of 'yeti_ac' type with any payload were sent.
#
# expect { subject }.to send_prometheus_metrics('yeti_ac').with(total: 5)
# # check that metric { type: 'yeti_ac', total: 5, metric_labels: {} } was sent.
#
# expect { subject }.to send_prometheus_metrics.with(total: 5, type: 'yeti_ac')
# # check that metric { type: 'yeti_ac', total: 5, metric_labels: {} } was sent.
#
# expect { subject }.to send_prometheus_metrics('yeti_ac')
#   .with(total: 5).with(foo: 'bar', metric_labels: { bar: 'baz' })
# # check that metrics { type: 'yeti_ac', total: 5, metric_labels: {} }
# # and { type: 'yeti_ac', foo: 'bar', metric_labels: { bar: 'baz' } } were sent.
#
# expect { subject }.to send_prometheus_metrics('yeti_ac')
#   .with(total: 5).with(foo: 'bar', metric_labels: { bar: 'baz' }).exactly(2)
# # check that metrics { type: 'yeti_ac', total: 5, metric_labels: {} }
# # and { type: 'yeti_ac', foo: 'bar', metric_labels: { bar: 'baz' } } were sent
# # and no other metric of type 'yeti_ac' were sent.
RSpec::Matchers.define :send_prometheus_metrics do |type = nil|
  supports_block_expectations
  diffable
  attr_reader :actual, :expected # needed to diffable

  # description do
  #   "sends prometheus metrics (type: #{type}) #{@expected_payload}"
  # end

  match do |action|
    @expected_payload ||= nil
    @expected = nil
    @exactly_check_failed = false

    old_metrics_size = RSpecTestPrometheusClient.instance.metrics.size
    action.call

    @actual = RSpecTestPrometheusClient.instance.metrics[old_metrics_size..-1]
    @actual = @actual.select { |m| m[:type] == type } unless type.nil?

    if @exactly && @actual.size != @exactly
      @exactly_check_failed = true
      return false
    end

    if @expected_payload
      @expected = @expected_payload.map do |payload|
        metric = { metric_labels: {} }.merge(payload)
        metric[:type] = type unless type.nil?
        metric
      end

      return values_match? match_array(@expected), @actual
    end

    if @exactly.nil? && @expected_payload.nil?
      return !@actual.empty?
    end

    return true
  end

  # def expected_formatted
  #   RSpec::Support::ObjectFormatter.format(@expected)
  # end

  # with can be hash or array of hashes
  # hash_including or any other matchers does not supported here.
  chain :with do |payload|
    raise ArgumentError, "with can't be nil" if payload.nil?

    @expected_payload ||= []
    @expected_payload.concat Array.wrap(payload)
  end

  # exactly must be an integer >= 0.
  # matchers does not supported here.
  chain :exactly do |payload|
    payload = Integer(payload)
    raise ArgumentError, 'exactly must be >= 0' if payload < 0

    @exactly = payload
  end

  failure_message do |_action|
    if @exactly_check_failed
      actual_formatted = RSpec::Support::ObjectFormatter.format(@actual)
      "expected metrics to be sent#{" with type #{type}" if type}: exactly #{@exactly}\nbut got #{@actual.size} metrics: #{actual_formatted}"
    else
      # with check failed
      expected_formatted = RSpec::Support::ObjectFormatter.format(@expected)
      actual_formatted = RSpec::Support::ObjectFormatter.format(@actual)
      "expected metrics to be sent#{" with type #{type}" if type}: #{expected_formatted}\nbut got metrics: #{actual_formatted}"
    end
  end
end
