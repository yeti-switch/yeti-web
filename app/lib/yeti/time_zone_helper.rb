# frozen_string_literal: true

module Yeti
  class TimeZoneHelper
    # Lazily loads all timezones into memory. 597 entries
    # returns array of String
    def self.all
      return @cached_entries if @cached_entries

      timezone_names = Cdr::Base.connection.select_values('SELECT name FROM pg_timezone_names ORDER BY name')

      @cached_entries = timezone_names.each_with_object([]) do |entry, valid_entries|
        name = Yeti::TimeZone.new(entry).name
        # PostgreSQL exposes helper names such as `localtime` or `posixrules` that ActiveSupport
        # cannot build, so filter them out to keep only valid Rails time zones.
        valid_entries << name if ActiveSupport::TimeZone.new(name)
      end
    end
  end
end
