# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::PopsController do
  include_context :clickhouse_dictionaries_api_helpers, type: :pops

  describe 'GET /api/rest/clickhouse-dictionaries/pops' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:pops) do
      FactoryBot.create_list(:pop, 2)
    end

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        pops.map { |record| { id: record.id, name: record.name } }
      end
    end
  end
end
