# frozen_string_literal: true

config_path = Rails.root.join('config/click_house.yml')
if config_path.exist?
  cfg = Rails.application.config_for(config_path)
  ClickHouse.config do |config|
    config.logger = Rails.logger
    config.assign(cfg)
    # Ask ClickHouse to render query exceptions *inside* the (JSON) output format
    # rather than as a raw "Code: ..." body, so the JSON parser never chokes on an
    # error response. Callers detect failures via the HTTP status and the
    # "exception" attribute in the parsed body.
    config.global_params = config.global_params.merge(http_write_exception_in_output_format: 1)
  end

  # AnsiStrippingLogger lives in app/lib (autoloaded), which isn't resolvable at
  # initializer-eval time — defer wiring it as the CH logger until the app is
  # initialized (the transport is built lazily on first query, after this). It
  # strips the gem's hardcoded ANSI color codes so journald doesn't render the
  # SQL log lines as "[N blob data]".
  Rails.application.config.to_prepare do
    ClickHouse.config { |c| c.logger = AnsiStrippingLogger.new(Rails.logger) }
  end
end
