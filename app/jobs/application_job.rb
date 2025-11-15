# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include CaptureError::JobMethods

  MAX_UNHANDLED_ATTEMPTS = 10

  rescue_from StandardError, with: :handle_unexpected_error

  private

  def handle_unexpected_error(error)
    capture_error(error)
    executions = executions_for(StandardError)
    if executions < MAX_UNHANDLED_ATTEMPTS
      wait = determine_delay(seconds_or_duration_or_algorithm: :polynomially_longer, executions:)
      retry_job(wait: wait, error: error)
    else
      instrument :retry_stopped, error: error
      run_after_discard_procs(error)
      raise error
    end
  end
end
