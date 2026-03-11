# frozen_string_literal: true

require 'httpx'

module CdrProcessor
  module Processors
    class CdrHttpBase < CdrProcessor::ConsumerGroup
      AVAILABLE_HTTP_METHODS = %i[post put patch].freeze

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

        unless AVAILABLE_HTTP_METHODS.include?(http_method)
          raise ArgumentError, "unsupported HTTP method '#{http_method}', should be one of: post, put, patch"
        end

        response = send_http_request(payload)
        log_response(response)
      rescue StandardError => e
        logger.error { "#{log_prefix} <#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
        raise e
      end

      def send_http_request(payload)
        kwargs = { headers: http_headers, body: http_body(payload) }
        client = HTTPX
        if logger.debug?
          client = client.with(debug: logger, debug_level: 1)
        end
        if @params['auth_user'].present?
          client = client.plugin(:basic_auth).basic_auth(@params['auth_user'], @params['auth_password'].to_s)
        end
        response = client.public_send(http_method, http_url, **kwargs)
        response.raise_for_status
        response
      end

      def log_prefix
        "request_id=#{@request_id} batch_id=#{@batch_id} event_id=#{@current_event_id}"
      end

      def log_response(response)
        logger.info { "#{log_prefix} status=#{response.status}" }
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
