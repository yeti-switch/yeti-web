# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::NodesController do
  include_context :clickhouse_dictionaries_api_helpers, type: :nodes

  describe 'GET /api/rest/clickhouse-dictionaries/nodes' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:nodes) do
      FactoryBot.create_list(:node, 2)
    end

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        nodes.map { |record| { id: record.id, name: record.name, pop_id: record.pop_id } }
      end
    end
  end
end
