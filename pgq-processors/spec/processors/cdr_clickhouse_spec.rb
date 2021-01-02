# frozen_string_literal: true

require TestContext.root_path.join('processors/cdr_clickhouse').to_s

RSpec.describe CdrClickhouse do
  subject do
    consumer.perform_group events.map(&:stringify_keys)
  end

  let(:consumer) do
    CdrClickhouse.new(TestContext.logger, 'cdr_billing', 'cdr_clickhouse', config.deep_stringify_keys)
  end
  let(:config) do
    {
      url: 'https://clickhouse.com/cdrs',
      clickhouse_db: 'foo',
      clickhouse_table: 'bar',
      cdr_fields: 'all'
    }
  end
  let(:events) do
    [
      {
        id: 1,
        duration: 14,
        time_start: '2020-12-29T15:46:35+03:00',
        time_connect: '2020-12-30T15:46:45+03:00',
        time_end: '2020-12-31T15:46:59+03:00',
        is_last_cdr: true,
        local_tag: SecureRandom.uuid
      },
      {
        id: 2,
        duration: 0,
        time_start: '2020-12-28T15:46:40+03:00',
        time_connect: nil,
        time_end: nil,
        is_last_cdr: false,
        local_tag: SecureRandom.uuid
      }
    ]
  end

  let!(:stub_clickhouse_request) do
    WebMock.stub_request(:post, config[:url])
           .with(query: expected_query, body: expected_body)
           .and_return(status: response_status, body: nil)
  end
  let(:expected_query) do
    { query: "INSERT INTO #{config[:clickhouse_db]}.#{config[:clickhouse_table]} FORMAT JSONEachRow" }
  end
  let(:expected_body) do
    [
      {
        id: 1,
        duration: 14,
        time_start: '2020-12-29 12:46:35',
        time_connect: '2020-12-30 12:46:45',
        time_end: '2020-12-31 12:46:59',
        is_last_cdr: 1,
        local_tag: events[0][:local_tag],
        date_start: '2020-12-29'
      },
      {
        id: 2,
        duration: 0,
        time_start: '2020-12-28 12:46:40',
        time_connect: nil,
        time_end: nil,
        is_last_cdr: 0,
        local_tag: events[1][:local_tag],
        date_start: '2020-12-28'
      }
    ].map(&:to_json).join("\n")
  end
  let(:response_status) { 204 }

  context 'permit all attributes' do
    it 'sends correct request to click house' do
      subject
      expect(stub_clickhouse_request).to have_been_requested
    end
  end

  context 'permit array attribute' do
    let(:config) { super().merge cdr_fields: %w[id local_tag] }
    let(:expected_body) do
      [
        { id: 1, local_tag: events[0][:local_tag] },
        { id: 2, local_tag: events[1][:local_tag] }
      ].map(&:to_json).join("\n")
    end

    it 'sends correct request to click house' do
      subject
      expect(stub_clickhouse_request).to have_been_requested
    end
  end
end
