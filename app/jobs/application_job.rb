# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include CaptureError::JobMethods

  rescue_from StandardError, with: :capture_error!
end
