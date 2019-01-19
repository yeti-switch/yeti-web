# frozen_string_literal: true

class Report::Realtime::Base < Cdr::Cdr
  self.abstract_class = true

  INTERVALS = [
    ['1 Minute', 1.minute],
    ['5 Minutes', 5.minute],
    ['10 Minutes', 10.minute],
    ['15 Minutes', 15.minute],
    ['1 Hour', 1.hour],
    ['3 Hours', 3.hours],
    ['1 Day', 1.day]
  ].freeze

  DEFAULT_INTERVAL = 60
end
