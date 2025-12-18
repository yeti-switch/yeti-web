# frozen_string_literal: true

RSpec.shared_examples :clickhouse_stub_requested do
  it 'sends correct query to ClickHouse' do
    subject
    expect(stub_clickhouse_query).to have_been_requested.once
  end
end
