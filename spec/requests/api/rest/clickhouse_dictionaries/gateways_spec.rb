# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::GatewaysController do
  include_context :clickhouse_dictionaries_api_helpers, type: :gateways

  describe 'GET /api/rest/clickhouse-dictionaries/gateways' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:gateways) { create_list(:gateway, 3) + [create(:gateway, external_id: 123)] }

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        gateways.map do |record|
          {
            id: record.id,
            name: record.name,
            external_id: record.external_id,
            origination_capacity: record.origination_capacity,
            termination_capacity: record.termination_capacity,
            enabled: record.enabled,
            gateway_group_id: record.gateway_group_id,
            allow_origination: record.allow_origination,
            allow_termination: record.allow_termination
          }
        end
      end
    end
  end
end
