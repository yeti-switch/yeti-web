# frozen_string_literal: true

RSpec.shared_examples :clickhouse_stub_not_requested do
  it 'does not send query to ClickHouse' do
    subject
    expect(stub_clickhouse_query).not_to have_been_requested
  end
end
