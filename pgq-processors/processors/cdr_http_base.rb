# frozen_string_literal: true

require 'rest-client'

class CdrHttpBase < Pgq::ConsumerGroup
  AVAILABLE_HTTP_METHODS = %i[post put get patch].freeze

  def initialize(...)
    super(...)
    # data_filters: [{field:, op:, value:}]
    if @params['data_filters'].present?
      @data_filters = @params['data_filters'].map { |opts| ::EventFilter.new(**opts.transform_keys(&:to_sym)) }
    else
      @data_filters = nil
    end
  end

  def perform_events(events)
    perform_group events.map(&:data)
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
    { content_type: :json, accept: :json }
  end

  def perform_http_request(payload)
    unless AVAILABLE_HTTP_METHODS.include?(http_method)
      raise ArgumentError, 'external_crd_endpoint.method should be one of post, put, get patch'
    end

    body = http_body(payload)
    args = [http_url, body]
    args.push(http_headers) if http_method.to_sym != :get
    response = RestClient.public_send(http_method, *args)
    log_response(response)
  rescue StandardError => e
    logger.error { "<#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
    raise e
  end

  def log_response(response)
    if response.code.to_i >= 400
      logger.error { "Request failed #{response.code} #{response.body}" }
    else
      logger.info { "Success #{response.code} #{response.body}" }
    end
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
