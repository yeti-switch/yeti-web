# frozen_string_literal: true

RSpec.describe '/api/rest/clickhouse-dictionaries/networks' do
  subject do
    get clickhouse_dictionary_path
  end

  include_context :clickhouse_dictionaries_api_helpers do
    let(:clickhouse_dictionary_type) { 'networks' }
  end

  let!(:networks) do
    [
      create(:network),
      create(:network, name: 'Other')
    ]
  end

  include_examples :responds_with_correct_json_each_row do
    let(:expected_rows) do
      networks.map { |record| { id: record.id, name: record.name } }
    end
  end
end
