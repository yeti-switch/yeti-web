# frozen_string_literal: true

require 'rest-client'

class CdrHttp < Pgq::ConsumerGroup
  AVAILABLE_HTTP_METHODS = %i[post put get patch].freeze

  @consumer_name = 'cdr_http'

  def perform_events(events)
    perform_group(events.map(&:data))
  end

  def perform_group(group)
    send_events_to_external group
  end

  private

  def log_response(response)
    if response.code.to_i >= 400
      logger.error "Request failed #{response.code} #{response.body}"
    else
      logger.info "Success #{response.code} #{response.body}"
    end

    response
  end

  def make_request_params(data)
    if http_method == :get
      [{ params: data }]
    else
      [data.to_json, { content_type: :json, accept: :json }]
    end
  end

  def http_method
    @params['method'].downcase.to_sym
  end

  def permit_field_for(event)
    permitted_field = @params['cdr_fields']

    if permitted_field == 'all' || permitted_field.nil?
      event.dup
    else
      event.select { |key, _value| permitted_field.include? key.to_s }
    end
  end

  def send_event_to_external(event)
    method = http_method

    unless AVAILABLE_HTTP_METHODS.include? method
      raise ArgumentError, 'external_crd_endpoint.method should be one of post, put, get patch'
    end

    logger.info "Sending cdr #{event.try :id}"

    response = RestClient.try(method, @params['url'], *make_request_params(permit_field_for(event)))

    log_response response
  rescue StandardError => e
    logger.error e.message
    logger.error e.backtrace.join "\n"
  end

  def send_events_to_external(group)
    group.map { |event| send_event_to_external event }
  end
end
