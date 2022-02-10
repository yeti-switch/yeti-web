# frozen_string_literal: true

require 'prometheus/active_calls_processor'

module Jobs
  class CallsMonitoring < ::BaseJob
    self.cron_line = '* * * * *'

    class CallCollection
      MONITORING_INTERVAL = 60

      attr_reader :collection,
                  :key,
                  :balance, :min_balance, :max_balance

      # @param collection [Array<Hash>]
      # @param key [Symbol]
      # @param account [Array]
      def initialize(collection, key:, account:)
        @collection = collection
        @key = key
        @balance = account[0]
        @min_balance = account[1]
        @max_balance = account[2]
      end

      def normal_calls
        collection.select do |c|
          c[call_reverse_billing_key] == false && c[:customer_acc_check_balance]
        end
      end

      def reverse_calls
        collection.select do |c|
          c[call_reverse_billing_key] == true && c[:customer_acc_check_balance]
        end
      end

      def exceed_min_balance?
        balance_after_calls < min_balance
      end

      def exceed_max_balance?
        balance_after_calls > max_balance
      end

      # normal  calls: '+'
      # reverse calls: '-'
      def total_calls_cost
        collection.inject(0) do |sum, call|
          if call[call_reverse_billing_key] == false
            sum + call_price(call)
          else
            sum - call_price(call)
          end
        end
      end

      private

      def call_reverse_billing_key
        :"#{key}_reverse_billing"
      end

      # Customer: every call charges balance
      # Vendor: every call adds funds to the balance
      def balance_after_calls
        if key == :destination
          balance - total_calls_cost
        elsif key == :dialpeer
          balance + total_calls_cost
        end
      end

      #   :destination_fee
      #   :destination_initial_interval
      #   :destination_initial_rate
      #   :destination_next_interval
      #   :destination_next_rate
      # or
      #   :dialpeer_fee,
      #   :dialpeer_initial_interval,
      #   :dialpeer_initial_rate,
      #   :dialpeer_next_interval,
      #   :dialpeer_next_rate
      #
      # attrs hash with calls attributes
      # key  'destination' | 'dialpeer'
      #
      def call_price(attrs)
        i_per_second_rate = attrs.fetch(:"#{key}_initial_rate").to_f / 60.0
        n_per_second_rate = attrs.fetch(:"#{key}_next_rate").to_f / 60.0
        # duration that will be on next calls monitoring run
        duration = attrs.fetch(:duration).to_i + MONITORING_INTERVAL # TODO: check if needed cast to int
        initial_interval = attrs.fetch(:"#{key}_initial_interval").to_i # TODO: check if needed cast to int
        next_interval = attrs.fetch(:"#{key}_next_interval").to_i # TODO: check if needed cast to int
        connect_fee = attrs.fetch(:"#{key}_fee").to_f
        vat = key == 'destination' ? attrs.fetch(:customer_acc_vat, 0).to_f : 0
        initial_interval_billing = connect_fee + initial_interval * i_per_second_rate
        next_interval_billing = (duration > initial_interval ? 1 : 0) * ((duration - initial_interval).to_f / next_interval).ceil * next_interval * n_per_second_rate
        (initial_interval_billing + next_interval_billing) * (1 + vat / 100.0)
      end
    end # END CallCollection

    attr_reader :now

    MONITORED_COLUMNS = [
      :orig_gw_id, # link to gateway, drop call if not enabled or if not allow_origination
      :term_gw_id, # link to gateway, drop call if not enabled or if not allow_termination
      :dialpeer_id,
      :node_id,
      :local_tag,

      :customer_acc_id,
      :destination_initial_interval,
      :destination_initial_rate,
      :destination_next_interval,
      :destination_next_rate,
      :destination_fee,
      :customer_acc_vat,

      :vendor_acc_id,
      :dialpeer_fee,
      :dialpeer_initial_interval,
      :dialpeer_initial_rate,
      :dialpeer_next_interval,
      :dialpeer_next_rate,

      :customer_acc_check_balance,
      :destination_reverse_billing,
      :dialpeer_reverse_billing,

      :duration,

      :customer_auth_id, # link to CustomersAuth, drop calls when CustomersAuth#reject_calls=true
      :customer_id, # link to contractor, drop call if contractor is not enabled or not customer
      :vendor_id, # link to contractor, drop call if contractor is not enabled or not vendor

      :customer_acc_external_id,
      :vendor_acc_external_id

    ].freeze

    def after_start
      @terminate_calls = {}
      @now = Time.now
    end

    def execute
      detect_customers_calls_to_reject
      detect_customers_auth_calls_to_reject
      detect_vendors_calls_to_reject
      detect_gateway_calls_to_reject
      detect_random_calls_to_reject
    end

    # random_disconnect_enable        | f
    # random_disconnect_length        | 7000
    def detect_random_calls_to_reject
      if GuiConfig.random_disconnect_enable
        max_length = GuiConfig.random_disconnect_length
        flatten_calls.each do |call|
          next if call[:duration].to_i <= max_length

          @terminate_calls.merge!(call[:local_tag] => call) if rand(100) < 10
        end
      end
    end

    def detect_customers_calls_to_reject
      customers_active_calls.each do |acc_id, calls|
        account = active_customers_balances[acc_id]

        if account
          call_collection = CallCollection.new(calls,
                                               key: :destination,
                                               account: account)

          if call_collection.exceed_min_balance?
            @terminate_calls.merge!(
              call_collection
                .normal_calls
                .index_by { |c| c[:local_tag] }
            )
          end

          if call_collection.exceed_max_balance?
            @terminate_calls.merge!(
              call_collection
                .reverse_calls
                .index_by { |c| c[:local_tag] }
            )
          end
        else
          # account not found so drop all calls
          @terminate_calls.merge!(calls.index_by { |c| c[:local_tag] })

        end
      end
    end

    def detect_vendors_calls_to_reject
      vendors_active_calls.each do |acc_id, calls|
        vendor = active_vendors_balances[acc_id]

        if vendor
          call_collection = CallCollection.new(calls,
                                               key: :dialpeer,
                                               account: vendor)
          # drop reverse-billing calls when balance reaches minimum
          if call_collection.exceed_min_balance?
            @terminate_calls.merge!(
              call_collection
                .reverse_calls
                .index_by { |c| c[:local_tag] }
            )
          end

          # drop normal calls when balance reaches maximum
          if call_collection.exceed_max_balance?
            @terminate_calls.merge!(
              call_collection
                .normal_calls
                .index_by { |c| c[:local_tag] }
            )
          end
        else
          # account not found so drop all calls
          @terminate_calls.merge!(calls.index_by { |c| c[:local_tag] })
        end
      end
    end

    # drop calls where `customer_auth_id`
    # is linked to `CustoemrsAuth#reject_calls = true`
    def detect_customers_auth_calls_to_reject
      flatten_calls.each do |call|
        customers_auth_id = call[:customer_auth_id]
        customers_auth = active_customers_auths_reject_calls[customers_auth_id]

        if customers_auth && customers_auth[1]
          @terminate_calls.merge!(call[:local_tag] => call)
        end
      end
    end

    # detect gateway is disabled by orig_gw_id and term_gw_id
    def detect_gateway_calls_to_reject
      flatten_calls.each do |call|
        if disabled_orig_gw_active_calls.key?(call[:orig_gw_id]) || disabled_term_gw_active_calls.key?(call[:term_gw_id])
          local_tag = call[:local_tag]
          @terminate_calls[local_tag] = call
        end
      end
    end

    def flatten_calls
      @flatten_calls ||= active_calls.values.flatten
    end

    def customers_active_calls
      @customers_active_calls ||= flatten_calls.group_by { |c| c[:customer_acc_id] }
    end

    def vendors_active_calls
      @vendors_active_calls ||= flatten_calls.group_by { |c| c[:vendor_acc_id] }
    end

    # returns hash with keys as ids of disabled gateways for origination
    def disabled_orig_gw_active_calls
      @disabled_orig_gw_active_calls ||= begin
        gw_ids = flatten_calls.collect { |c| c[:orig_gw_id] }.uniq
        Hash[Gateway.disabled_for_origination.where(id: gw_ids).pluck(:id).zip]
      end
    end

    # returns hash with keys as ids of disabled gateways for termination
    def disabled_term_gw_active_calls
      @disabled_term_gw_active_calls ||= begin
        gw_ids = flatten_calls.collect { |c| c[:term_gw_id] }.uniq
        Hash[Gateway.disabled_for_termination.where(id: gw_ids).pluck(:id).zip]
      end
    end

    #
    #  returns array of hashes
    #  [ {account_id => [balance, min_balance, max_balance, account_id]}]
    #
    def active_customers_balances
      @active_customers_balances ||= Account.customers_accounts
                                            .merge(Contractor.enabled)
                                            .where(id: active_customers_ids)
                                            .pluck(:balance, :min_balance, :max_balance, :id).index_by { |c| c[3] }
    end

    #
    #  returns array of hashes
    #  [ {vendor_id => [balance,  min_balance, max_balance, vendor_id]}]
    #
    def active_vendors_balances
      @active_vendors_balances ||= Account.vendors_accounts
                                          .merge(Contractor.enabled)
                                          .where(id: active_vendors_ids)
                                          .pluck(:balance, :min_balance, :max_balance, :id).index_by { |c| c[3] }
    end

    # returns array of hashes
    # [ { customer_auth_id => [reject_calls] }, ... ]
    def active_customers_auths_reject_calls
      @active_customers_auths_reject_calls ||= begin
        CustomersAuth
          .where(id: active_customers_auth_ids)
          .pluck(:id, :reject_calls).index_by { |c| c[0] }
      end
    end

    # unique list of all customer_acc_id from all current calls
    def active_customers_ids
      @active_customers_ids ||= flatten_calls.collect { |c| c[:customer_acc_id] }.uniq
    end

    # unique list of all vendor_acc_id from all current calls
    def active_vendors_ids
      @active_vendors_ids ||= flatten_calls.collect { |c| c[:vendor_acc_id] }.uniq
    end

    def active_customers_auth_ids
      @active_customers_auth_ids ||= flatten_calls.collect { |c| c[:customer_auth_id] }.uniq
    end

    def active_calls
      @active_calls ||= begin
        calls = Yeti::CdrsFilter.new(Node.all).raw_cdrs(only: MONITORED_COLUMNS, empty_on_error: true)
        Rails.logger.info { " total calls count: #{calls.count} " }
        calls.group_by { |c| c[:node_id] }
      end
    end

    def before_finish
      save_stats
      send_prometheus_metrics
      terminate_calls!
    end

    private

    def send_prometheus_metrics
      return unless PrometheusConfig.enabled?

      metrics = []

      total = active_calls.values.sum(&:count)
      metrics << ActiveCallsProcessor.collect(total: total)

      customers_active_calls.each do |account_id, calls|
        account_external_id = calls.first[:customer_acc_external_id]
        collection = CallCollection.new(calls, key: :destination, account: [])
        src_prefixes = calls.map { |c| c[:src_prefix_routing] }
        dst_prefixes = calls.map { |c| c[:dst_prefix_routing] }

        metrics << ActiveCallsProcessor.collect(
            account_originated: calls.count,
            account_originated_unique_src: src_prefixes.uniq.count,
            account_originated_unique_dst: dst_prefixes.uniq.count,
            account_price_originated: collection.total_calls_cost,
            labels: { account_external_id: account_external_id, account_id: account_id }
          )
      end

      vendors_active_calls.each do |account_id, calls|
        account_external_id = calls.first[:vendor_acc_external_id]
        collection = CallCollection.new(calls, key: :dialpeer, account: [])

        metrics << ActiveCallsProcessor.collect(
            account_terminated: calls.count,
            account_price_terminated: collection.total_calls_cost,
            labels: { account_external_id: account_external_id, account_id: account_id }
          )
      end

      client = PrometheusExporter::Client.default
      metrics.each { |metric| client.send_json(metric) }
    end

    def save_stats
      Stats::ActiveCall.transaction do
        Stats::ActiveCall.create_stats(active_calls, now)
        if YetiConfig.calls_monitoring.write_account_stats
          ActiveCalls::CreateAccountStats.call(
            customer_calls: customers_active_calls,
            vendor_calls: vendors_active_calls,
            current_time: now
          )
        end
        orig_gw_grouped_calls = flatten_calls.group_by { |c| c[:orig_gw_id] }
        Stats::ActiveCallOrigGateway.create_stats(orig_gw_grouped_calls, now)
        term_gw_grouped_calls = flatten_calls.group_by { |c| c[:term_gw_id] }
        Stats::ActiveCallTermGateway.create_stats(term_gw_grouped_calls, now)
      end
    end

    def terminate_calls!
      nodes = Node.all.index_by(&:id)
      @terminate_calls.each do |local_tag, call|
        logger.warn { "CallsMonitoring#terminate_calls! Node #{call[:node_id]}, local_tag :#{local_tag}" }
        begin
          node_id = call[:node_id].to_i
          nodes[node_id].drop_call(local_tag)
        rescue StandardError => e
          node_id = call.is_a?(Hash) ? call[:node_id] : nil
          capture_error(e, extra: { local_tag: local_tag, node_id: node_id })
          logger.error e.message
        end
      end
    end
  end
end
