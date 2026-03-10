# frozen_string_literal: true

require 'httpx'

module CdrProcessor
  module Processors
    class CdrHttpBase < CdrProcessor::ConsumerGroup
      AVAILABLE_HTTP_METHODS = %i[post put get patch].freeze

      def initialize(...)
        super(...)
        # data_filters: [{field:, op:, value:}]
        if @params['data_filters'].present?
          @data_filters = @params['data_filters'].map { |opts| CdrProcessor::EventFilter.new(**opts.transform_keys(&:to_sym)) }
        else
          @data_filters = nil
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
        { 'content-type' => 'application/json', 'accept' => 'application/json' }
      end

      def perform_http_request(payload)
        unless AVAILABLE_HTTP_METHODS.include?(http_method)
          raise ArgumentError, 'external_crd_endpoint.method should be one of post, put, get, patch'
        end

        response = send_http_request(payload)
        log_response(response)
      rescue StandardError => e
        logger.error { "<#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
        raise e
      end

      def send_http_request(payload)
        kwargs = { headers: http_headers }
        if http_method == :get
          kwargs[:params] = payload
        else
          kwargs[:body] = http_body(payload)
        end
        client = HTTPX
        if @params['auth_user'].present?
          client = client.plugin(:basic_auth).basic_auth(@params['auth_user'], @params['auth_password'].to_s)
        end
        response = client.public_send(http_method, http_url, **kwargs)
        response.raise_for_status
        response
      end

      def log_response(response)
        logger.info { "Success #{response.status} #{response.body}" }
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
