# frozen_string_literal: true

RSpec.shared_examples :returns_json_api_record_relationship do |name, status: 200|
  let(:json_api_record_data) { response_json[:data] }
  let(:json_api_relationship_data) { nil }

  it "returns json api record with correct #{name} relationship data" do
    subject
    expect(response.status).to(
      eq(status),
      "expect response.status to eq #{status}, but got #{response.status}\n#{pretty_response_json}"
    )
    name = name.to_sym
    actual_relationships = json_api_record_data[:relationships]
    expect(actual_relationships.key?(name)).to(
      eq(true),
      "expect relationships to have key #{name}, but not found in\n#{actual_relationships}"
    )
    expect(actual_relationships[name].key?(:data)).to(
      eq(true),
      "expect relationship to have data, but it's not\n#{actual_relationships[name]}"
    )
    expect(actual_relationships[name][:data]).to eq(json_api_relationship_data)
  end
end
