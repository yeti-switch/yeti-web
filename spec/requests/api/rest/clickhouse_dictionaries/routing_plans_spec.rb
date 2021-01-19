# frozen_string_literal: true

RSpec.describe Api::Rest::ClickhouseDictionaries::RoutingPlansController do
  include_context :clickhouse_dictionaries_api_helpers, type: :'routing-plans'

  describe 'GET /api/rest/clickhouse-dictionaries/routing-plans' do
    subject do
      get clickhouse_dictionary_request_path
    end

    let!(:routing_plans) { create_list(:routing_plan, 3) }

    include_examples :responds_with_correct_json_each_row do
      let(:expected_rows) do
        routing_plans.map { |record| { id: record.id, name: record.name, external_id: record.external_id } }
      end
    end
  end
end
