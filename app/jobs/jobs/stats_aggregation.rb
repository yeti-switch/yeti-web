module Jobs
  class StatsAggregation < ::BaseJob

    def execute
      aggregate(Stats::ActiveCall, Stats::AggActiveCall, :node_id)
      aggregate(Stats::ActiveCallCustomerAccount, Stats::AggActiveCallCustomerAccount, :account_id)
      aggregate(Stats::ActiveCallVendorAccount, Stats::AggActiveCallVendorAccount, :account_id)
      aggregate(Stats::ActiveCallOrigGateway, Stats::AggActiveCallOrigGateway, :gateway_id)
      aggregate(Stats::ActiveCallTermGateway, Stats::AggActiveCallTermGateway, :gateway_id)
    end

    def before_finish
      destroy_old
    end

    protected

    def day_ago
      @day_ago ||= 24.hours.ago
    end



    def destroy_old
      Stats::ActiveCall.where('created_at < ?', day_ago).delete_all
      Stats::ActiveCallCustomerAccount.where('created_at < ?', day_ago).delete_all
      Stats::ActiveCallVendorAccount.where('created_at < ?', day_ago).delete_all
      Stats::ActiveCallOrigGateway.where('created_at < ?', day_ago).delete_all
      Stats::ActiveCallTermGateway.where('created_at < ?', day_ago).delete_all
    end

    def aggregate(klass_from, klass_to, entity_key)
      klass_from.transaction do
        klass_from.where('created_at < ?', day_ago).
            select("max(count),min(count),avg(count),#{entity_key},date_trunc('hour',created_at)").
            group("#{entity_key},date_trunc('hour',created_at)").to_a.each do |line|
          klass_to.create!(
              entity_key => line.attributes["#{entity_key}"],
              max_count: line.attributes['max'],
              min_count: line.attributes['min'],
              calls_time: line.attributes['date_trunc'],
              avg_count: line.attributes['avg']
          )
        end
      end
    end
  end

end