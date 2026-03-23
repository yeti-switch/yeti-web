# frozen_string_literal: true

# Always load the gem so the Sentry constant is available (e.g. in test stubs),
# but only run the full configuration when sentry is enabled and not in a Rake task.
require 'sentry-ruby'

if CaptureError.enabled? && !defined?(::Rake)
  CaptureError.configure!
end
