# frozen_string_literal: true

RSpec.shared_context :clickhouse_dictionaries_api_helpers do |type: nil|
  let(:clickhouse_dictionary_resource_type) { type.to_s }
  let(:clickhouse_dictionary_request_path_prefix) { '/api/rest/clickhouse-dictionaries' }
  let(:clickhouse_dictionary_request_path) { "#{clickhouse_dictionary_request_path_prefix}/#{clickhouse_dictionary_resource_type}" }

  def response_json_each_row
    response.body.split("\n").map { |row| JSON.parse(row).deep_symbolize_keys }
  rescue StandardError
    nil
  end
end
