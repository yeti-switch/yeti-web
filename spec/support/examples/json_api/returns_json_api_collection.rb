# frozen_string_literal: true

RSpec.shared_examples :returns_json_api_collection do |respect_sorting: false, type: nil|
  let(:json_api_collection_ids) do
    raise NotImplementedError, 'define let(:json_api_collection_ids) in shared_examples :returns_json_api_collection'
  end
  let(:json_api_collection_type) { type || json_api_resource_type }

  it 'returns json api collection of records' do
    subject
    expect(response.status).to(
      eq(200),
      "expect response.status to eq 200, but got #{response.status}\n#{pretty_response_json}"
    )
    expected_ids = respect_sorting ? json_api_collection_ids : match_array(json_api_collection_ids)
    expect(response_json[:data].map { |d| d[:id] }).to match(expected_ids)
    expect(response_json[:data].map { |d| d[:type] }.uniq).to eq([json_api_collection_type])
  end
end
