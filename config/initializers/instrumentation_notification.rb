# frozen_string_literal: true

module ActionController
  # Adds instrumentation to several ends in ActionController::Base. It also provides
  # some hooks related with process_action, this allows an ORM like Active Record
  # and/or DataMapper to plug in ActionController and show related information.
  #
  # Check ActiveRecord::Railties::ControllerRuntime for an example.
  module Instrumentation
    def append_info_to_raw_payload(raw_payload)
      # nothing
    end

    def process_action(*args)
      raw_payload = {
        controller: self.class.name,
        action: action_name,
        params: request.filtered_parameters,
        format: request.format.try(:ref),
        method: request.method,
        # tags can be removed in the future in favor to use inside in ApiLogger
        tags: ApiLogger.tags,
        path: (begin
                      request.fullpath
               rescue StandardError
                 'unknown'
                    end)
      }
      append_info_to_raw_payload(raw_payload)

      ActiveSupport::Notifications.instrument('start_processing.action_controller', raw_payload.dup)

      ActiveSupport::Notifications.instrument('process_action.action_controller', raw_payload) do |payload|
        result = super
        payload[:status] = response.status
        payload[:meta] = try(:meta)
        append_info_to_payload(payload)
        result
      end
    end
  end
end

ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |_name, start, finish, _id, payload|
  if payload[:path].start_with? '/api/'
    begin
      ApiLogger.log!(
        message_field: %i[status method path controller remote_ip],
        payload: payload.merge(page_duration: (finish - start) * 1000)
      )
    rescue StandardError => e
      Rails.logger.error { "#{e.message}\n#{e.backtrace&.join("\n")}" }
      CaptureError.capture(e, tags: { component: 'API Logs' })
    end
  end
end
