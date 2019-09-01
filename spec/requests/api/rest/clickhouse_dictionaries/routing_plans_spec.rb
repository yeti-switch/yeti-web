# frozen_string_literal: true

RSpec.describe '/api/rest/clickhouse-dictionaries/routing-plans' do
  subject do
    get clickhouse_dictionary_path
  end

  include_context :clickhouse_dictionaries_api_helpers do
    let(:clickhouse_dictionary_type) { 'routing-plans' }
  end

  let!(:routing_plans) { create_list(:routing_plan, 3) }

  include_examples :responds_with_correct_json_each_row do
    let(:expected_rows) do
      routing_plans.map { |record| { id: record.id, name: record.name } }
    end
  end
end
