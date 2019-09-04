# frozen_string_literal: true

RSpec.describe '/api/rest/clickhouse-dictionaries/countries' do
  subject do
    get clickhouse_dictionary_path
  end

  include_context :clickhouse_dictionaries_api_helpers do
    let(:clickhouse_dictionary_type) { 'countries' }
  end

  let!(:countries) do
    [
      create(:country, name: 'Canada', iso2: 'CA'),
      create(:country, name: 'United Stated', iso2: 'US')
    ]
  end

  include_examples :responds_with_correct_json_each_row do
    let(:expected_rows) do
      countries.map { |record| { id: record.id, name: record.name, iso2: record.iso2 } }
    end
  end
end
