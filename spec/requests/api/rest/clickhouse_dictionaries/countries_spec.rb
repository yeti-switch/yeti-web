# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::CountriesController do
  include_context :clickhouse_dictionaries_api_helpers, type: :countries

  describe 'GET /api/rest/clickhouse-dictionaries/countries' do
    subject do
      get clickhouse_dictionary_request_path
    end

    before do
      System::NetworkPrefix.delete_all
      System::Country.delete_all
    end
    let!(:countries) do
      FactoryBot.create_list(:country, 2, :uniq_name)
    end

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        countries.map { |record| { id: record.id, name: record.name, iso2: record.iso2 } }
      end
    end
  end
end
