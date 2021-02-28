# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::AccountsController do
  include_context :clickhouse_dictionaries_api_helpers, type: :accounts

  describe 'GET /api/rest/clickhouse-dictionaries/accounts' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:accounts) { create_list(:account, 3) + [create(:account, external_id: 123)] }

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        accounts.map do |record|
          record.reload
          {
            id: record.id,
            name: record.name,
            external_id: record.external_id,
            origination_capacity: record.origination_capacity,
            termination_capacity: record.termination_capacity,
            total_capacity: record.total_capacity,
            uuid: record.uuid
          }
        end
      end
    end

    context 'when raises exception' do
      before do
        expect(ClickhouseDictionary::Account).to receive(:call).once
                                                               .and_raise(StandardError, 'test error')
      end

      include_examples :raises_exception, StandardError, 'test error'
      include_examples :captures_error, safe: true, request: true
    end
  end
end
