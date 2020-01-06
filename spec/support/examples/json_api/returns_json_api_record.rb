# frozen_string_literal: true

RSpec.shared_examples :returns_json_api_record do |relationships: [], type: nil, status: 200|
  let(:json_api_record_data) { response_json[:data] } # can be overridden to check one of collection's item
  let(:json_api_record_id) { nil }
  let(:json_api_record_attributes) { nil }
  let(:json_api_record_type) { type || json_api_resource_type }

  it 'returns json api record with correct data' do
    subject
    expect(response.status).to(
      eq(status),
      "expect response.status to eq #{status}, but got #{response.status}\n#{pretty_response_json}"
    )
    expect(json_api_record_data[:id]).to match(json_api_record_id)
    expect(json_api_record_data[:type]).to eq(json_api_record_type)
    expect(json_api_record_data[:attributes]).to match(json_api_record_attributes)
    actual_relationships = json_api_record_data[:relationships]&.keys || []
    expect(actual_relationships).to match_array(relationships)
  end
end
