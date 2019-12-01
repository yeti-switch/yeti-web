# frozen_string_literal: true

module CaptureError
  module ControllerMethods
    extend ActiveSupport::Concern
    include ::CaptureError::BaseMethods

    def capture_tags
      {
        request_id: request.request_id,
        controller_name: params[:controller],
        action_name: params[:action]
      }
    end

    def capture_message(message, options = {})
      super message, options.merge(request_env: request.env)
    end

    def capture_error(exception, options = {})
      super exception, options.merge(request_env: request.env)
    end
  end
end
