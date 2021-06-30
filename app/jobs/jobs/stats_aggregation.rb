# frozen_string_literal: true

module Jobs
  class StatsAggregation < ::BaseJob
    self.cron_line = '25 * * * *'

    def execute
      aggregate(Stats::ActiveCall, Stats::AggActiveCall, :node_id)
      aggregate_account
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
      Stats::ActiveCallAccount.where('created_at < ?', day_ago).delete_all
      Stats::ActiveCallOrigGateway.where('created_at < ?', day_ago).delete_all
      Stats::ActiveCallTermGateway.where('created_at < ?', day_ago).delete_all
    end

    def aggregate(klass_from, klass_to, entity_key)
      klass_from.transaction do
        klass_from.where('created_at < ?', day_ago)
                  .select("max(count),min(count),avg(count),#{entity_key},date_trunc('hour',created_at)")
                  .group("#{entity_key},date_trunc('hour',created_at)").to_a.each do |line|
          klass_to.create!(
            entity_key => line.attributes[entity_key.to_s],
            max_count: line.attributes['max'],
            min_count: line.attributes['min'],
            calls_time: line.attributes['date_trunc'],
            avg_count: line.attributes['avg']
          )
        end
      end
    end

    def aggregate_account
      scope = Stats::ActiveCallAccount.where('created_at < ?', day_ago)
                                      .group("account_id,date_trunc('hour',created_at)")
                                      .select(
                                        'max(originated_count) AS max_originated_count',
                                        'min(originated_count) AS min_originated_count',
                                        'avg(originated_count) AS avg_originated_count',
                                        'max(terminated_count) AS max_terminated_count',
                                        'min(terminated_count) AS min_terminated_count',
                                        'avg(terminated_count) AS avg_terminated_count',
                                        'account_id',
                                        "date_trunc('hour',created_at)"
                                      )

      Stats::ActiveCallAccount.transaction do
        scope.to_a.each do |line|
          Stats::AggActiveCallAccount.create!(
            account_id: line.attributes['account_id'],
            calls_time: line.attributes['date_trunc'],
            max_originated_count: line.attributes['max_originated_count'],
            min_originated_count: line.attributes['min_originated_count'],
            avg_originated_count: line.attributes['avg_originated_count'],
            max_terminated_count: line.attributes['max_terminated_count'],
            min_terminated_count: line.attributes['min_terminated_count'],
            avg_terminated_count: line.attributes['avg_terminated_count']
          )
        end
      end
    end
  end
end
