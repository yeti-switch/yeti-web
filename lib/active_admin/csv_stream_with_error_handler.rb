# frozen_string_literal: true

module ActiveAdmin
  module CsvStreamWithErrorHandler
    protected

    def stream_resource(&)
      block_with_error_handler = wrap_stream_error_handling(&)
      super(&block_with_error_handler)
    end

    private

    # When we stream response block is executed in Puma after rails done with request.
    # All exceptions are rescued and suppressed.
    def wrap_stream_error_handling
      error_context = capture_context
      proc do |csv|
        yield(csv)
      rescue StandardError => e
        CaptureError.log_error(e)
        CaptureError.capture(e, error_context)
        raise e
      end
    end
  end
end
