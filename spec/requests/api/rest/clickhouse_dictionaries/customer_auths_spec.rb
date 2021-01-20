# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::CustomerAuthsController do
  include_context :clickhouse_dictionaries_api_helpers, type: :'customer-auths'

  describe 'GET /api/rest/clickhouse-dictionaries/customer-auths' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:customer_auths) { create_list(:customers_auth, 2) + [create(:customers_auth, external_id: 123)] }

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        customer_auths.map do |record|
          {
            id: record.id,
            name: record.name,
            external_id: record.external_id,
            customer_id: record.customer_id,
            account_id: record.account_id,
            enabled: record.enabled
          }
        end
      end
    end
  end
end
