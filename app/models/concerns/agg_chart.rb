module AggChart
  extend ActiveSupport::Concern

  included do
    class_attribute :chart_entity_column
  end


  module ClassMethods

    def to_chart(id)
      res = {
          max: [],
          min: [],
          avg: []
      }
      where(self.chart_entity_column => id).
          where('created_at > ? AND created_at < NOW() ', 1.week.ago).
          order('calls_time').pluck(:calls_time, :max_count, :min_count, :avg_count).
          map do |d|
        x = d[0].to_datetime.to_s(:db)
        res[:max] << {x: x, y: d[1]}
        res[:min] << {x: x, y: d[2]}
        res[:avg] << {x: x, y: d[3]}

      end
      res.map do |k, v|
        {
            values: v,
            key: k
        }
      end

    end

  end

end