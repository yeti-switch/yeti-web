# frozen_string_literal: true

module Yeti
  module TimeZoneHelper
    # Lazily loads all timezones into memory. 597 entries
    def all
      return @cached_entries if @cached_entries

      @cached_entries = Cdr::Base.connection.select_values('SELECT name FROM pg_timezone_names ORDER BY name').map do |i|
        Yeti::TimeZone.new(i)
      end
    end

    module_function :all
  end
end
