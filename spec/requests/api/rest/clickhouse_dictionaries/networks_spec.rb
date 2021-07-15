# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::NetworksController do
  include_context :clickhouse_dictionaries_api_helpers, type: :networks

  describe 'GET /api/rest/clickhouse-dictionaries/networks' do
    subject do
      get clickhouse_dictionary_request_path
    end

    before do
      System::NetworkPrefix.delete_all
      System::Network.delete_all
    end
    let!(:networks) do
      FactoryBot.create_list(:network, 2, :uniq_name)
    end

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        networks.map { |record| { id: record.id, name: record.name } }
      end
    end
  end
end
