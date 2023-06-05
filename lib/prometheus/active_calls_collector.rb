# frozen_string_literal: true

class ActiveCallsCollector < PrometheusExporter::Server::TypeCollector
  MAX_METRIC_AGE = 30
  TOTAL_HELP = 'total active calls by all accounts'
  ORIG_ACCOUNT_GAUGES = {
    account_originated: 'total calls originated by account',
    account_originated_unique_src: 'qty of unique src_routing_number originated by account',
    account_originated_unique_dst: 'qty of unique dst_routing_number originated by account',
    account_price_originated: 'total origination price for calls originated by account'
  }.freeze
  TERM_ACCOUNT_GAUGES = {
    account_terminated: 'total calls terminated to account',
    account_price_terminated: 'total termination price for calls originated by account'
  }.freeze
  ORIG_CUSTOMER_AUTH_GAUGES = {
    ca: 'total calls originated by customer auth',
    ca_price_originated: 'total origination price for calls originated by customer auth'
  }.freeze
  GAUGES = {
    **ORIG_ACCOUNT_GAUGES,
    **TERM_ACCOUNT_GAUGES,
    **ORIG_CUSTOMER_AUTH_GAUGES
  }.freeze
  ORIG_ACCOUNT_KEYS = ActiveCallsCollector::ORIG_ACCOUNT_GAUGES.keys.map(&:to_s).freeze
  TERM_ACCOUNT_KEYS = ActiveCallsCollector::TERM_ACCOUNT_GAUGES.keys.map(&:to_s).freeze
  ORIG_CUSTOMER_AUTH_KEYS = ActiveCallsCollector::ORIG_CUSTOMER_AUTH_GAUGES.keys.map(&:to_s).freeze

  def initialize
    @data = []

    @observers = {}
    GAUGES.each do |name, desc|
      @observers[name.to_s] = PrometheusExporter::Metric::Gauge.new("#{type}_#{name}", desc)
    end
    @observers['total'] = PrometheusExporter::Metric::Gauge.new(type, TOTAL_HELP)

    @orig_accounts = []
    @term_accounts = []
    @orig_customer_auths = []
  end

  def type
    'yeti_ac'
  end

  def metrics
    @observers.each_value(&:reset!)

    @orig_accounts.each do |account_labels|
      @observers.slice(*ORIG_ACCOUNT_KEYS).each do |_, observer|
        observer.observe(0, account_labels)
      end
    end
    @term_accounts.each do |account_labels|
      @observers.slice(*TERM_ACCOUNT_KEYS).each do |_, observer|
        observer.observe(0, account_labels)
      end
    end
    @orig_customer_auths.each do |customer_auth_labels|
      @observers.slice(*ORIG_CUSTOMER_AUTH_KEYS).each do |_, observer|
        observer.observe(0, customer_auth_labels)
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

  # It receives following objects from processor:
  #   @example
  #     { metric_labels, custom_labels, total }
  #     { metric_labels, custom_labels, account_originated, account_originated_unique_src, ... }
  #     { metric_labels, custom_labels, account_terminated, account_price_terminated }
  #     { metric_labels, custom_labels, ca, ca_price_originated }
  # @see Jobs::CallsMonitoring#send_prometheus_metrics
  def collect(obj)
    labels = gather_labels(obj)
    if labels.key?('account_id') && obj.key?('account_terminated')
      @term_accounts.push(labels) unless @term_accounts.include?(labels)
    elsif labels.key?('account_id') && obj.key?('account_originated')
      @orig_accounts.push(labels) unless @orig_accounts.include?(labels)
    elsif labels.key?('id') && obj.key?('ca')
      @orig_customer_auths.push(labels) unless @orig_customer_auths.include?(labels)
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
