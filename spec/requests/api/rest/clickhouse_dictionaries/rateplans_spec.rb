# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::RateplansController do
  include_context :clickhouse_dictionaries_api_helpers, type: :rateplans

  describe 'GET /api/rest/clickhouse-dictionaries/rateplans' do
    subject do
      get clickhouse_dictionary_request_path
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
end
