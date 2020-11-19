# frozen_string_literal: true

module BillingPeriod
  class Base
    class_attribute :_split_period, instance_accessor: false, default: false
    class_attribute :days_in_period, instance_accessor: false

    class << self
      # @param flag [Boolean]
      def split_period(flag = true)
        self._split_period = flag
      end

      # @return [Boolean]
      def split_period?
        _split_period
      end

      # Calculate period_end for provided time within period in provided time zone.
      # @param time [Time] time within period in provided time zone.
      # @param time_zone [ActiveSupport::TimeZone]
      # @return [Time] period_end in provided time zone.
      def period_end_for(time_zone, time)
        new(time_zone).period_end_for(time)
      end

      # Calculate period start by period end.
      # @param period_end [Time,Date]
      # @param time_zone [ActiveSupport::TimeZone]
      # @return [Time] time in provided time zone.
      def period_start_for(time_zone, period_end)
        new(time_zone).period_start_for(period_end)
      end
    end

    # @!method time_zone [ActiveSupport::TimeZone]
    attr_reader :time_zone

    # @param time_zone [ActiveSupport::TimeZone]
    def initialize(time_zone)
      @time_zone = time_zone
    end

    # Calculate period_end for provided time within period in provided time zone.
    # @param time [Time] time within period in provided time zone.
    # @return [Time] period_end in provided time zone.
    def period_end_for(time)
      raise NotImplementedError
    end

    # Calculate period start by period end for provided time zone.
    # @param period_end [Time] period_end in provided time zone.
    # @return [Time] period_start in provided time zone.
    def period_start_for(period_end)
      raise NotImplementedError
    end

    private

    # @param date [Date]
    # @return [Time] Time object that represents date in provided time zone.
    def date_to_time_in_time_zone(date)
      time_zone.parse("#{date.year}-#{date.month}-#{date.day}")
    end
  end
end
