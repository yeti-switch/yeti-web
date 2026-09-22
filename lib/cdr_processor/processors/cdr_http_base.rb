# frozen_string_literal: true

require 'httpx'

module CdrProcessor
  module Processors
    class CdrHttpBase < CdrProcessor::ConsumerGroup
      # Raised for any response that is neither an HTTPX error nor 2xx, i.e. in
      # practice for redirects. HTTPX#raise_for_status only fails on 4xx/5xx, so
      # without this a 301/302 (endpoint moved, plain HTTP redirected to HTTPS,
      # a proxy or auth portal answering instead of the endpoint) would count as
      # a successful delivery: the batch gets finished and the CDRs are dropped
      # although the endpoint never received them.
      class UnexpectedResponseStatus < StandardError
        attr_reader :response

        def initialize(response)
          @response = response
          message = "unexpected HTTP status #{response.status} (expected 2xx)"
          location = response.headers['location']
          message += ", location: #{location}" if location.present?
          super(message)
        end
      end

      # HTTPX writes its debug lines to an IO-like with `<<`, that SemanticLogger has not.
      class DebugStream
        def initialize(logger)
          @logger = logger
        end

        def <<(message)
          @logger.debug(message.chomp)
        end
      end

      AVAILABLE_HTTP_METHODS = %i[post put patch].freeze
      SUCCESS_STATUSES = (200..299)
      # Defaults, each overridable by the same key in the processor config (seconds).
      HTTP_TIMEOUTS = {
        connect_timeout: 20,
        write_timeout: 30,
        read_timeout: 30,
        request_timeout: 60
      }.freeze

      def initialize(...)
        super(...)
        # data_filters: [{field:, op:, value:}]
        if @params['data_filters'].present?
          @data_filters = @params['data_filters'].map { |opts| CdrProcessor::EventFilter.new(**opts.transform_keys(&:to_sym)) }
        else
          @data_filters = nil
        end
        custom_headers = @params['headers'] || {}
        @custom_headers = custom_headers.reject { |key, _| key.casecmp('user-agent').zero? }
        @http_timeouts = HTTP_TIMEOUTS.to_h do |key, default|
          value = @params[key.to_s]
          [key, value.nil? ? default : Float(value)]
        end
      end

      def perform_events(events)
        perform_group_with_timing events.map(&:data)
      end

      def perform_group(events)
        events.each do |event|
          next unless send_event?(event)

          perform_http_request permit_field_for(event)
        end
      end

      private

      def send_event?(event)
        return true if @data_filters.nil?

        @data_filters.all? { |filter| filter.match?(event) }
      end

      def http_method
        :post
      end

      def http_url
        @params['url']
      end

      def http_body(payload)
        payload.to_json
      end

      def http_headers
        @custom_headers.merge('X-Request-Id' => @request_id)
      end

      def perform_http_request(payload)
        @request_id = SecureRandom.uuid
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        SemanticLogger.named_tagged({ request_id: @request_id, event_id: @current_event_id }.compact) do
          unless AVAILABLE_HTTP_METHODS.include?(http_method)
            raise ArgumentError, "unsupported HTTP method '#{http_method}', should be one of: post, put, patch"
          end

          response = send_http_request(payload)
          log_request(:info, 'HTTP request completed', response.status, start_time)
        rescue StandardError => e
          log_request(:error, "HTTP request failed: <#{e.class}> #{e.message}", exception_http_status(e), start_time)
          raise e
        end
      end

      def send_http_request(payload)
        kwargs = { headers: http_headers, body: http_body(payload) }
        client = HTTPX.with(timeout: @http_timeouts)
        if logger.debug?
          client = client.with(debug: DebugStream.new(logger), debug_level: 1)
        end
        if @params['auth_user'].present?
          client = client.plugin(:basic_auth).basic_auth(@params['auth_user'], @params['auth_password'].to_s)
        end
        client = proxy.apply(client)
        response = proxy.run { client.public_send(http_method, http_url, **kwargs) }
        response.raise_for_status
        raise UnexpectedResponseStatus, response unless SUCCESS_STATUSES.cover?(response.status)

        response
      end

      # Outbound HTTP proxy for CDR export requests, controlled per processor via
      # http_proxy / use_env_proxy in config/cdr_processors.yml; see HttpxProxy.
      def proxy
        @proxy ||= HttpxProxy.new(http_proxy: @params['http_proxy'], use_env_proxy: @params['use_env_proxy'])
      end

      # http_status is a named tag, not a payload field: YetiLogFormatter puts named tags
      # at the root of the record, next to request_id and batch_id.
      def log_request(level, message, http_status, start_time)
        duration = elapsed_ms(start_time)
        SemanticLogger.named_tagged({ http_status: http_status }.compact) do
          logger.public_send(level, message: message, duration: duration)
        end
      end

      # HTTPX::HTTPError and UnexpectedResponseStatus carry the response, timeouts do not.
      def exception_http_status(exception)
        response = exception.response if exception.respond_to?(:response)
        response.status if response.respond_to?(:status)
      end

      def permit_field_for(event)
        permitted_field = @params['cdr_fields']

        if permitted_field == 'all' || permitted_field.nil?
          event.dup
        else
          event.select { |key, _value| permitted_field.include? key.to_s }
        end
      end
    end
  end
end
