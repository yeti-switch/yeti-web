# frozen_string_literal: true

RSpec.describe '/api/rest/clickhouse-dictionaries/rateplans' do
  subject do
    get clickhouse_dictionary_path
  end

  include_context :clickhouse_dictionaries_api_helpers do
    let(:clickhouse_dictionary_type) { 'rateplans' }
  end

  let!(:rateplan) { create_list(:rateplan, 3) }

  include_examples :responds_with_correct_json_each_row do
    let(:expected_rows) do
      rateplan.map do |record|
        record.reload
        { id: record.id, name: record.name, uuid: record.uuid, external_id: record.external_id }
      end
    end
  end
end
