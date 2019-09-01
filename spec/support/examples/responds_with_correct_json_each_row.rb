# frozen_string_literal: true

RSpec.shared_examples :responds_with_correct_json_each_row do
  # let(:expected_rows) define is required
  # Depends on shared_context :clickhouse_dictionaries_api_helpers
  # Usage:
  #
  #   include_examples :responds_with_correct_json_each_row do
  #     let(:expected_rows) { [ { foo: 'bar' }, { foo: 'baz'} ] }
  #   end

  it 'responds with correct JsonEachRow and status 200' do
    subject
    rows = response_json_each_row

    expect(response.status).to(
      eq(200),
      -> { "expected: 200\ngot: #{response.status}\nBODY:\n#{rows || response.body.inspect}" }
    )
    expect(rows).to(
      be_present,
      -> { "expected JsonEachRow to be present\ngot: #{response.body.inspect}" }
    )
    expect(rows.size).to(
      be > 0,
      -> { "expected JsonEachRow.size to be > 0\ngot: #{response.body}" }
    )
    expect(response_json_each_row).to match_array(expected_rows)
  end
end
