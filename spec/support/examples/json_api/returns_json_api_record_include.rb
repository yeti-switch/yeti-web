RSpec.shared_examples :returns_json_api_record_include do |type: nil, relationships: nil, status: 200|
  let(:json_api_include_type) { type.to_s unless type.nil? }
  let(:json_api_include_id) { nil }
  let(:json_api_include_attributes) { a_kind_of(Hash) }
  let(:json_api_include_relationships_names) { relationships || be_a_kind_of(Array) }

  it 'returns json api include with correct data' do
    subject
    expect(response.status).to(
        eq(status),
        "expect response.status to eq #{status}, but got #{response.status}\n#{pretty_response_json}"
    )
    included = response_json[:included]
    expect(included).to(
        be_present,
        "expect include to be present, but got #{included}\n#{pretty_response_json}"
    )
    actual_data = included.detect do |d|
      d[:id] == json_api_include_id && d[:type] == json_api_include_type
    end
    expect(actual_data).to(
        be_present,
        [
            "expect to find include with id #{json_api_include_id.inspect} and type #{json_api_include_type.inspect}",
            "but nothing was found in\n#{included}"
        ].join(' ')
    )
    expect(actual_data[:attributes]).to match(json_api_include_attributes)
    actual_relationships = actual_data[:relationships].keys
    expected_rel_names = json_api_include_relationships_names.is_a?(Array) ?
                             match_array(json_api_include_relationships_names) :
                             json_api_include_relationships_names
    expect(actual_relationships).to expected_rel_names
  end
end
