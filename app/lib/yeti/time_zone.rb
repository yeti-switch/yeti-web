# frozen_string_literal: true

module Yeti
  class TimeZone
    include WithQueryBuilder
    attr_reader :name

    def initialize(name)
      @name = name
      @time_zone = ActiveSupport::TimeZone[name]
    end

    def id
      name
    end

    class << self
      def query_builder_find(id, **_)
        timezone_present = Yeti::TimeZoneHelper.all.include?(id)
        timezone_present ? new(id) : nil
      end

      def query_builder_collection(filters:, none: false, **_)
        return [] if none

        names = Yeti::TimeZoneHelper.all
        names &= Array.wrap(filters[:name]).map(&:to_s) if filters[:name]
        names &= Array.wrap(filters[:id]).map(&:to_s) if filters[:id]
        names.map { |name| new(name) }
      end
    end

    private

    attr_reader :time_zone

    def time_in_zone
      @time_in_zone ||= time_zone&.now
    end
  end
end
