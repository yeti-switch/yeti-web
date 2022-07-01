# frozen_string_literal: true

module StatsAggregation
  class ActiveCall < Base
    private

    def stats_class
      Stats::ActiveCall
    end

    def agg_class
      Stats::AggActiveCall
    end

    def entity_key
      :node_id
    end
  end
end
