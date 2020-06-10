# frozen_string_literal: true

class Report::Realtime::Base < Cdr::Cdr
  self.abstract_class = true

  INTERVALS = [
    ['1 Minute', 1.minute],
    ['5 Minutes', 5.minutes],
    ['10 Minutes', 10.minutes],
    ['15 Minutes', 15.minutes],
    ['1 Hour', 1.hour],
    ['3 Hours', 3.hours],
    ['1 Day', 1.day]
  ].freeze

  DEFAULT_INTERVAL = 60
end
