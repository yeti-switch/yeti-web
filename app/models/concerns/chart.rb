module Chart
  extend ActiveSupport::Concern

  included do
     class_attribute :chart_entity_column
     class_attribute :chart_entity_klass
     scope :day_ago, -> { hours_ago(24)  }
     scope :hours_ago, ->(hours){ where('created_at > ? AND created_at < NOW() ', hours.hours.ago).order('created_at') }
  end

  module ClassMethods

    def create_stats(calls = {}, now_time)
      super calls, now_time, chart_entity_klass.all, chart_entity_column
    end


    def to_chart(id, options={})
      [{
           key: chart_entity_klass.find(id).name,
           area: true,
           values: self.where(chart_entity_column => id).day_ago.pluck(:created_at, :count).map { |d| {x: d[0].to_datetime.to_s(:db), y: d[1]} }
       }.merge(options)]
    end
  end

end