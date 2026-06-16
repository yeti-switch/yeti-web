# frozen_string_literal: true

require 'delegate'

# Logger decorator that strips ANSI escape sequences (color codes) from string
# messages before delegating to the wrapped logger.
#
# The click_house gem hardcodes color codes in its SQL log lines
# (ClickHouse::Middleware::Logging emits "\e[1m[35mSQL …\e[0m …" regardless of
# Rails' colorize_logging). Under journald those ESC bytes make the whole entry
# render as "[N blob data]" (only visible with `journalctl -a`). Stripping them
# keeps the ClickHouse query logs as plain, greppable text.
#
# Used for ClickHouse.config.logger (see config/initializers/click_house.rb).
class AnsiStrippingLogger < SimpleDelegator
  # Standard CSI color escape, plus an optional orphaned "[NNm" that immediately
  # follows it — the gem emits "\e[1m[35m" (the second code is missing its ESC),
  # so we only strip such a bare code when it trails a real escape.
  ANSI = /\e\[[\d;]*m(?:\[\d+m)?/

  %i[debug info warn error fatal unknown].each do |level|
    define_method(level) do |message = nil, *args, &block|
      message = message.gsub(ANSI, '') if message.is_a?(String)
      __getobj__.public_send(level, message, *args, &block)
    end
  end
end
