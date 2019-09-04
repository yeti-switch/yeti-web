# frozen_string_literal: true

RSpec.shared_context :clickhouse_dictionaries_api_helpers do
  let(:clickhouse_dictionary_path) do
    "/api/rest/clickhouse-dictionaries/#{clickhouse_dictionary_type}"
  end
  let(:clickhouse_dictionary_type) do
    raise "override let(:clickhouse_dictionary_type) in #{full_description.inspect} test"
  end

  def response_json_each_row
    response.body.split("\n").map { |row| JSON.parse(row).deep_symbolize_keys }
  rescue StandardError
    nil
  end
end
