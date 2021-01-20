# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::NetworkPrefixesController do
  include_context :clickhouse_dictionaries_api_helpers, type: :'network-prefixes'

  describe 'GET /api/rest/clickhouse-dictionaries/network-prefixes' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:network_prefixes) { create_list(:network_prefix, 3) }

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        network_prefixes.map do |record|
          {
            id: record.id,
            prefix: record.prefix,
            country_name: record.country.name,
            network_name: record.network.name,
            country_id: record.country_id,
            network_id: record.network_id
          }
        end
      end
    end
  end
end
