# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::AreasController do
  include_context :clickhouse_dictionaries_api_helpers, type: :areas

  describe 'GET /api/rest/clickhouse-dictionaries/areas' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:areas) { create_list(:area, 3) }

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        areas.map { |record| { id: record.id, name: record.name } }
      end
    end
  end
end
