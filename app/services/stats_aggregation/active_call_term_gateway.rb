# frozen_string_literal: true

module StatsAggregation
  class ActiveCallTermGateway < Base
    private

    def stats_class
      Stats::ActiveCallTermGateway
    end

    def agg_class
      Stats::AggActiveCallTermGateway
    end

    def entity_key
      :gateway_id
    end
  end
end
