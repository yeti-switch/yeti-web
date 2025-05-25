# frozen_string_literal: true

class ApiLogger
  include SemanticLogger::Loggable
  attr_reader :message, :payload

  ApiLogThread = Class.new(Thread)

  module CONST
    DB_ADAPTER = :db
    ELASTICSEARCH_ADAPTER = :elasticsearch
    VICTORIALOGS_ADAPTER = :victorialogs

    SUPPORTED_API_LOG_ADAPTERS = [
      DB_ADAPTER,
      ELASTICSEARCH_ADAPTER,
      VICTORIALOGS_ADAPTER
    ].freeze
  end

  def self.adapter
    adapter = YetiConfig.api_logs&.adapter&.to_sym

    # if adapter not configured or invalid, default to db
    return CONST::DB_ADAPTER if adapter.nil? || !CONST::SUPPORTED_API_LOG_ADAPTERS.include?(adapter)

    adapter
  end

  def self.tags
    YetiConfig.api_logs&.tags || YetiConfig.api_log_tags || []
  end

  def self.log!(message: '', message_field: nil, payload: {})
    new(message:, message_field:, payload:).log!
  end

  def initialize(message:, message_field:, payload:)
    @message = message
    @payload = parse_payload(payload)

    if message_field.present?
      @message += message_from_payload(message_field)
    end
  end

  def log!
    if [CONST::ELASTICSEARCH_ADAPTER, CONST::VICTORIALOGS_ADAPTER].include?(self.class.adapter)
      # for elasticsearch and victorialogs, we use the same semantic logger
      log_trough_logger!
    else
      log_to_db!
    end
  end

  private

  def log_to_db!
    ApiLogThread.new { Log::ApiLog.create!(payload) }
  end

  def log_trough_logger!
    logger.info(message:, payload:)
  end

  def parse_payload(payload)
    return parsed_payload if instance_variable_defined?(:@parsed_payload)

    parsed_payload = {}

    parsed_payload[:meta] = payload[:meta]
    parsed_payload[:remote_ip] = payload[:remote_ip]
    parsed_payload[:status] = payload[:status]

    if payload[:status].nil? && payload[:exception].present?
      parsed_payload[:status] = ActionDispatch::ExceptionWrapper.status_code_for_exception(payload[:exception].class)
    end

    parsed_payload[:path] = payload[:path].to_s.split('?').first
    parsed_payload[:page_duration] = payload[:page_duration]
    parsed_payload[:db_duration] = payload[:db_runtime]
    parsed_payload[:method] = payload[:method]
    parsed_payload[:tags] = payload[:tags]
    parsed_payload[:status] = payload[:status]
    parsed_payload[:controller] = payload[:controller]
    parsed_payload[:action] = payload[:action]
    parsed_payload[:params] = payload[:params].to_yaml

    if payload[:debug_mode]
      request_headers = payload[:request].headers.select { |key, _val| key.match('^HTTP.*') }
      parsed_payload[:request_headers] = Hash[*request_headers.flatten(1)].map { |k, v| "#{k}=#{v}" }.join("\n\r")
      parsed_payload[:request_body] = payload[:request].body.read
      parsed_payload[:response_body] = payload[:response].try(:body)
      parsed_payload[:response_headers] = (payload[:response].try(:headers) || {}).map { |k, v| "#{k}=#{v}" }.join("\n\r")
    end

    parsed_payload
  end

  def message_from_payload(message_field)
    if message_field.is_a?(Array)
      field_values = []
      message_field.each do |field|
        field_values << payload[field]
      end
      field_values.join(' ')
    else
      payload[message_field]
    end
  end
end
