# frozen_string_literal: true

module CaptureError
  module ControllerMethods
    extend ActiveSupport::Concern
    include ::CaptureError::BaseMethods

    def capture_context
      super.merge(rack_env: request.env)
    end

    def capture_tags
      {
        request_id: request.request_id,
        controller_name: params[:controller],
        action_name: params[:action]
      }
    end
  end
end
