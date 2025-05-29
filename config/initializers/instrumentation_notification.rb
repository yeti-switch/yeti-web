# frozen_string_literal: true

ApiLogThread = Class.new(Thread)
ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |_name, start, finish, _id, payload|
  api_log_enabled = YetiConfig.api_log_enabled.nil? ? true : YetiConfig.api_log_enabled
  next unless api_log_enabled
  next unless payload[:path].start_with?('/api/')

  ApiLogThread.new do
    Log::ApiLog.create do |api_log|
      request = payload[:request]

      api_log.meta = payload[:meta]
      api_log.tags = YetiConfig.api_log_tags || []

      api_log.remote_ip = request.env['HTTP_X_REAL_IP'] || request.remote_ip
      api_log.path = payload[:path].to_s.split('?').first
      api_log.page_duration = (finish - start) * 1000
      api_log.db_duration = payload[:db_runtime]
      api_log.method = payload[:method]
      api_log.status = payload[:status]
      api_log.controller = payload[:controller]
      api_log.action = payload[:action]
      api_log.params = payload[:params].to_yaml
      if payload[:debug_mode]
        request_headers = request.headers.select { |key, _val| key.match('^HTTP.*') }
        response_headers = payload[:response].try(:headers) || {}

        api_log.request_headers = Hash[*request_headers.flatten(1)].map { |k, v| "#{k}=#{v}" }.join("\n\r")
        api_log.request_body = request.raw_post
        api_log.response_body = payload[:response].try(:body)
        api_log.response_headers = response_headers.map { |k, v| "#{k}=#{v}" }.join("\n\r")
      end
    end
  rescue StandardError => e
    Rails.logger.error { "#{e.message}\n#{e.backtrace&.join("\n")}" }
    CaptureError.capture(e, tags: { component: 'API Logs' })
  end
end
