# frozen_string_literal: true

RSpec.describe '/api/rest/clickhouse-dictionaries/contractors' do
  subject do
    get clickhouse_dictionary_path
  end

  include_context :clickhouse_dictionaries_api_helpers do
    let(:clickhouse_dictionary_type) { 'contractors' }
  end

  let!(:contractors) { create_list(:vendor, 2) + [create(:customer, external_id: 123)] }

  include_examples :responds_with_correct_json_each_row do
    let(:expected_rows) do
      contractors.map do |record|
        {
          id: record.id,
          name: record.name,
          external_id: record.external_id,
          enabled: record.enabled,
          vendor: record.vendor,
          customer: record.customer
        }
      end
    end
  end
end
