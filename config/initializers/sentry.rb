# frozen_string_literal: true

require 'capture_error'

if CaptureError.enabled? && !defined?(::Rake)
  CaptureError.configure!
end
