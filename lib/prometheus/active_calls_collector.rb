# frozen_string_literal: true

class ActiveCallsCollector < PrometheusExporter::Server::TypeCollector
  MAX_METRIC_AGE = 30
  TOTAL_HELP = 'total active calls by all accounts'
  GAUGES = {
    account_originated: 'total calls originated by account',
    account_originated_unique_src: 'qty of unique src_routing_number originated by account',
    account_originated_unique_dst: 'qty of unique dst_routing_number originated by account',
    account_price_originated: 'total origination price for calls originated by account',
    account_terminated: 'total calls terminated to account',
    account_price_terminated: 'total termination price for calls originated by account'
  }.freeze

  def initialize
    @data = []

    @observers = {}
    GAUGES.each do |name, desc|
      @observers[name.to_s] = PrometheusExporter::Metric::Gauge.new("#{type}_#{name}", desc)
    end
    @observers['total'] = PrometheusExporter::Metric::Gauge.new(type, TOTAL_HELP)

    @orig_accounts = []
    @term_accounts = []
  end

  def type
    'yeti_ac'
  end

  def metrics
    @observers.each_value(&:reset!)

    @orig_accounts.each do |account_labels|
      @observers.except('total', 'account_terminated', 'account_price_terminated').each do |_, observer|
        observer.observe(0, account_labels)
      end
    end
    @term_accounts.each do |account_labels|
      @observers.slice('account_terminated', 'account_price_terminated').each do |_, observer|
        observer.observe(0, account_labels)
      end
    end

    @data.each do |obj|
      labels = gather_labels(obj)

      @observers.each do |name, observer|
        value = obj[name]
        observer.observe(value, labels) if value
      end
    end

    @observers.values.select { |m| m.data.present? }
  end

  #   @example { metric_labels, custom_labels, total }
  #   @example { metric_labels, custom_labels, account_originated, ... }
  def collect(obj)
    labels = gather_labels(obj)
    if labels.key?('account_id') && obj.key?('account_terminated')
      @term_accounts.push(labels) unless @term_accounts.include?(labels)
    elsif labels.key?('account_id')
      @orig_accounts.push(labels) unless @orig_accounts.include?(labels)
    end

    now = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    obj['created_at'] = now
    @data.delete_if { |m| m['created_at'] + MAX_METRIC_AGE < now }
    @data << obj
  end

  private

  def gather_labels(obj)
    labels = {}
    # labels are passed by processor
    labels.merge!(obj['metric_labels']) if obj['metric_labels']
    # custom_labels are passed by PrometheusExporter::Client
    labels.merge!(obj['custom_labels']) if obj['custom_labels']
    labels
  end
end
