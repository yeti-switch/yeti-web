module Jobs
  class CallsMonitoring < ::BaseJob

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

        :vendor_acc_id,
        :dialpeer_fee,
        :dialpeer_initial_interval,
        :dialpeer_initial_rate,
        :dialpeer_next_interval,
        :dialpeer_next_rate,

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
      customers_active_calls.each do |customer_id, calls|
        total_calls_amount = 0
        calls.each do |call|
          total_calls_amount += call_price(call, "destination")
        end

        if total_calls_amount > 0 and !active_customer_balance_enough?(customer_id.to_i, total_calls_amount)
          @terminate_calls.merge! calls.index_by { |c| c["local_tag"] }
        end

      end
    end

    def detect_vendors_calls_to_reject
      vendors_active_calls.each do |vendor_id, calls|
        total_calls_amount = 0
        calls.each do |call|
          total_calls_amount += call_price(call, "dialpeer")
        end
        if total_calls_amount > 0 and !active_vendor_balance_enough?(vendor_id.to_i, total_calls_amount)
          @terminate_calls.merge! calls.index_by { |c| c["local_tag"] }
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

    #
    #  returns array of hashes
    #  [ {account_id => [balance, min_balance, max_balance, account_id]}]
    #
    def active_customers_balances
      @active_customers_balances ||= Account.customers_accounts.where(:id => active_customers_ids).
          pluck(:balance, :min_balance, :max_balance, :id).index_by { |c| c[3] }
    end

    #amount + balance < min_balance
    def active_customer_balance_enough?(id, amount)
      logger.warn { "checking  enough balance for customer #{id}, #{amount} " }
      begin
        logger.warn { "balance: #{active_customers_balances()[id][0]}, min: #{active_customers_balances()[id][1]}, amount: #{amount} " }
        enough =    active_customers_balances()[id][0] - active_customers_balances()[id][1] > amount
        logger.warn { " enough  #{enough} " }
        enough
      rescue StandardError => e
        logger.error("active_customers_balances: #{id} => #{e.message} ")
        raise e
      end
    end

    #
    #  returns array of hashes
    #  [ {vendor_id => [balance,  min_balance, max_balance, vendor_id]}]
    #
    def active_vendors_balances
      @active_vendors_balances ||= Account.vendors_accounts.where(:id => active_vendors_ids).
          pluck(:balance, :min_balance, :max_balance, :id).index_by { |c| c[3] }
    end

    #amount + balance > max_balance
    def active_vendor_balance_enough?(id, amount)
      logger.warn { "checking  enough balance  for vendor  #{id}" }
      begin
        logger.warn { "balance: #{active_vendors_balances[id][0]}, max: #{active_vendors_balances[id][2]}, amount: #{amount} " }
        enough = active_vendors_balances[id][2] - active_vendors_balances[id][0] > amount
        logger.warn { " enough  #{enough} " }
        enough
      rescue StandardError => e
        logger.error("active_vendors_balances: #{id} => #{e.message} ")
        raise e
      end
    end

    #uniq list of all customer_acc_id from all current calls
    def active_customers_ids
      @active_customers_ids ||= flatten_calls.collect { |c| c["customer_acc_id"] }.uniq
    end

    #uniq list of all vendor_acc_id from all current calls
    def active_vendors_ids
      @active_vendors_ids ||= flatten_calls.collect { |c| c["vendor_acc_id"] }.uniq
    end

    # 'destination_fee': '0.0',
    #  'destination_initial_interval': 1,
    #  'destination_initial_rate': '0.0350',
    #     'destination_next_interval': 1,
    #     'destination_next_rate': '0.0350',
    #or
    #     :dialpeer_fee,
    #     :dialpeer_initial_interval,
    #     :dialpeer_initial_rate,
    #     :dialpeer_next_interval,
    #     :dialpeer_next_rate

    # attrs hash with calls attributes
    # key  destination | dialpeer

    def call_price(attrs, key)
      i_per_second_rate = attrs.fetch("#{key}_initial_rate").to_f / 60.0
      n_per_second_rate = attrs.fetch("#{key}_next_rate").to_f / 60.0
      duration = attrs.fetch('duration').to_i #todo check if needed cast to int
      initial_interval = attrs.fetch("#{key}_initial_interval").to_i #todo check if needed cast to int
      next_interval = attrs.fetch("#{key}_next_interval").to_i #todo check if needed cast to int
      connect_fee = attrs.fetch("#{key}_fee").to_f

      initial_interval_billing = connect_fee + initial_interval * i_per_second_rate
      next_interval_billing = (duration > initial_interval ? 1 : 0) * ((duration - initial_interval).to_f / next_interval).ceil * next_interval * n_per_second_rate
      initial_interval_billing + next_interval_billing
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
        logger.warn { "CallsMonitoring#terminate_calls! node #{call['node_id']}, local_tag :#{local_tag}" }
        begin
          nodes[call['node_id'].to_i].drop_call(local_tag)
        rescue StandardError => e
          logger.error e.message
        end
      end
    end

  end
end