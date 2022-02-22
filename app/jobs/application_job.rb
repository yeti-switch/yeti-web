# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include CaptureError::JobMethods

  rescue_from StandardError, with: :capture_error!
  class_attribute :_unique_name, instance_accessor: false

  class << self
    def unique_name(value)
      self._unique_name = value
    end
  end
end
