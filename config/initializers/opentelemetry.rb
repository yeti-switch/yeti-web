# frozen_string_literal: true

if YetiConfig.telemetry&.enabled
  require 'opentelemetry/sdk'
  require 'opentelemetry/instrumentation/all'

  OpenTelemetry::SDK.configure do |c|
    c.service_name = 'yeti-web'
    c.use_all # enables all instrumentation!
  end
end
