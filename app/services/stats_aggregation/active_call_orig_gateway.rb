# frozen_string_literal: true

module StatsAggregation
  class ActiveCallOrigGateway < Base
    private

    def stats_class
      Stats::ActiveCallOrigGateway
    end

    def agg_class
      Stats::AggActiveCallOrigGateway
    end

    def entity_key
      :gateway_id
    end
  end
end
