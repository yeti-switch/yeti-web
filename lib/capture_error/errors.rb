# frozen_string_literal: true

module CaptureError
  module Errors
    class SentFailed < StandardError
      def initialize
        super('sentry sent failed')
      end
    end
  end
end
