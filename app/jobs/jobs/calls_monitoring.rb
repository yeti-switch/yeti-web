module Jobs
  class CallsMonitoring < ::BaseJob

    class CallCollection
      attr_reader :collection,
                  :key,
                  :balance, :min_balance, :max_balance

      def initialize(collection, key:, account:)
        @collection = collection
        @key = key
        @balance = account[0]
        @min_balance = account[1]
        @max_balance = account[2]
      end

      def normal_calls
        collection.select do |c|
         c[call_reverse_billing_key] == false && c['customer_acc_check_balance']
        end
      end

      def reverse_calls
        collection.select do |c|
         c[call_reverse_billing_key] == true && c['customer_acc_check_balance']
        end
      end

      def exceed_min_balance?
        balance_after_calls < min_balance
      end

      def exceed_max_balance?
        balance_after_calls > max_balance
      end

      private

      def call_reverse_billing_key
        "#{key}_reverse_billing"
      end

      # Customer: every call charges balance
      # Vendor: every call adds funds to the balance
      def balance_after_calls
        if key == 'destination'
          balance - total_calls_cost
        elsif key == 'dialpeer'
          balance + total_calls_cost
        end
      end

      # normal  calls: '+'
      # reverse calls: '-'
      def total_calls_cost
        collection.inject(0) do |sum, call|
          if call[call_reverse_billing_key] == false
            sum += call_price(call)
          else
            sum -= call_price(call)
          end
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
        i_per_second_rate = attrs.fetch("#{key}_initial_rate").to_f / 60.0
        n_per_second_rate = attrs.fetch("#{key}_next_rate").to_f / 60.0
        duration = attrs.fetch('duration').to_i #TODO: check if needed cast to int
        initial_interval = attrs.fetch("#{key}_initial_interval").to_i #TODO: check if needed cast to int
        next_interval = attrs.fetch("#{key}_next_interval").to_i #TODO: check if needed cast to int
        connect_fee = attrs.fetch("#{key}_fee").to_f
        vat =  key == 'destination' ? attrs.fetch("customer_acc_vat", 0) : 0
        initial_interval_billing = connect_fee + initial_interval * i_per_second_rate
        next_interval_billing = (duration > initial_interval ? 1 : 0) * ((duration - initial_interval).to_f / next_interval).ceil * next_interval * n_per_second_rate
        (initial_interval_billing + next_interval_billing) * (1 + vat / 100.0)
      end

    end #END CallCollection


    attr_reader :now

    MONITORED_COLUMNS = [
        :orig_gw_id,
        :term_gw_id,
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

        :duration
    ].freeze

    def after_start
      @terminate_calls = {}
      @now = Time.now
    end

    def execute
      detect_customers_calls_to_reject
      detect_vendors_calls_to_reject
      detect_random_calls_to_reject
      detect_gateway_calls_to_reject
    end

    # random_disconnect_enable        | f
    # random_disconnect_length        | 7000
    def detect_random_calls_to_reject
      if GuiConfig.random_disconnect_enable
        max_length = GuiConfig.random_disconnect_length
        flatten_calls.each do |call|
          if call['duration'] > max_length
            if rand(100) < 10
              @terminate_calls.merge!({call['local_tag'] => call})
            end
          end
        end
      end
    end

    def detect_customers_calls_to_reject
      customers_active_calls.each do |acc_id, calls|
        call_collection = CallCollection.new(calls,
                                             key: 'destination',
                                             account: active_customers_balances()[acc_id])

        if call_collection.exceed_min_balance?
          @terminate_calls.merge!(
            call_collection
              .normal_calls
              .index_by { |c| c["local_tag"] }
          )
        end

        if call_collection.exceed_max_balance?
          @terminate_calls.merge!(
            call_collection
              .reverse_calls
              .index_by { |c| c["local_tag"] }
          )
        end
      end
    end

    def detect_vendors_calls_to_reject
      vendors_active_calls.each do |acc_id, calls|
        call_collection = CallCollection.new(calls,
                                             key: 'dialpeer',
                                             account: active_vendors_balances()[acc_id])
        # drop reverse-billing calls when balance reaches minimum
        if call_collection.exceed_min_balance?
          @terminate_calls.merge!(
            call_collection
              .reverse_calls
              .index_by { |c| c["local_tag"] }
          )
        end

        # drop normal calls when balance reaches maximum
        if call_collection.exceed_max_balance?
          @terminate_calls.merge!(
            call_collection
              .normal_calls
              .index_by { |c| c["local_tag"] }
          )
        end
      end
    end

    # detect gateway is disabled by orig_gw_id and term_gw_id
    def detect_gateway_calls_to_reject
      flatten_calls.each do |call|
        if disabled_gw_active_calls.key?(call['orig_gw_id']) || disabled_gw_active_calls.key?(call['term_gw_id'])
            @terminate_calls.merge!({call['local_tag'] => call})
        end
      end
    end


    def flatten_calls
      @flatten_calls ||= active_calls.values.flatten
    end

    def customers_active_calls
      @customers_active_calls ||= flatten_calls.group_by { |c| c["customer_acc_id"] }
    end

    def vendors_active_calls
      @vendors_active_calls ||= flatten_calls.group_by { |c| c["vendor_acc_id"] }
    end

    #returns hash with keys as ids of disabled gateways
    def disabled_gw_active_calls
      @disabled_gw_active_calls ||= begin
        active_gw_ids = flatten_calls.collect { |c| [ c["orig_gw_id"], c["term_gw_id"] ]}.flatten.uniq
        Hash[Gateway.where(enabled: false).where(id: active_gw_ids).pluck(:id).zip]
      end
    end

    #
    #  returns array of hashes
    #  [ {account_id => [balance, min_balance, max_balance, account_id]}]
    #
    def active_customers_balances
      @active_customers_balances ||= Account.customers_accounts.where(:id => active_customers_ids).
          pluck(:balance, :min_balance, :max_balance, :id).index_by { |c| c[3] }
    end

    #
    #  returns array of hashes
    #  [ {vendor_id => [balance,  min_balance, max_balance, vendor_id]}]
    #
    def active_vendors_balances
      @active_vendors_balances ||= Account.vendors_accounts.where(:id => active_vendors_ids).
          pluck(:balance, :min_balance, :max_balance, :id).index_by { |c| c[3] }
    end

    #unique list of all customer_acc_id from all current calls
    def active_customers_ids
      @active_customers_ids ||= flatten_calls.collect { |c| c["customer_acc_id"] }.uniq
    end

    #unique list of all vendor_acc_id from all current calls
    def active_vendors_ids
      @active_vendors_ids ||= flatten_calls.collect { |c| c["vendor_acc_id"] }.uniq
    end

    def active_calls
      @active_calls ||= begin
        calls = Yeti::CdrsFilter.new(Node.all).raw_cdrs(only: MONITORED_COLUMNS, empty_on_error: true)
        Rails.logger.info { " total calls count: #{calls.count} " }
        calls.group_by { |c| c['node_id'] }
      end
    end

    def before_finish
      save_stats
      terminate_calls!

    end

    private

    def save_stats
      Stats::ActiveCall.transaction do
        Stats::ActiveCall.create_stats(active_calls, now)
        Stats::ActiveCallCustomerAccount.create_stats(customers_active_calls, now)

        Stats::ActiveCallVendorAccount.create_stats(vendors_active_calls, now)
        orig_gw_grouped_calls = flatten_calls.group_by { |c| c["orig_gw_id"] }
        Stats::ActiveCallOrigGateway.create_stats(orig_gw_grouped_calls, now)
        term_gw_grouped_calls = flatten_calls.group_by { |c| c["term_gw_id"] }
        Stats::ActiveCallTermGateway.create_stats(term_gw_grouped_calls, now)
      end
    end

    def terminate_calls!
      nodes = Node.all.index_by(&:id)
      @terminate_calls.each do |local_tag, call|
        logger.warn { "CallsMonitoring#terminate_calls! Node #{call['node_id']}, local_tag :#{local_tag}" }
        begin
          nodes[call['node_id'].to_i].drop_call(local_tag)
        rescue StandardError => e
          logger.error e.message
        end
      end
    end

  end
end
