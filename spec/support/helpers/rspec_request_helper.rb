# frozen_string_literal: true

module RspecRequestHelper
  def response_json
    data = JSON.parse(response.body)
    data.is_a?(Array) ? data.map(&:deep_symbolize_keys) : data.deep_symbolize_keys
  rescue StandardError => e
    Rails.logger.error { "response_json parsing failed with #{e.class}: #{e.message}" }
    nil
  end

  def pretty_response_json
    JSON.pretty_generate(response_json)
  end
end
