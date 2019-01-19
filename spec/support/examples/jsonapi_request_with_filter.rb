# frozen_string_literal: true

RSpec.shared_examples :jsonapi_request_with_filter do
  let(:attr_value) { 'Default String value to make testing easier' }
  let(:request_filters) { { attr_name => attr_value.to_s } }

  before do
    @expected_record = expected_record
  end

  subject do
    get :index, params: { filter: request_filters }
  end

  it 'response contains only one fitting record' do
    subject
    expect(response_data).to match_array(
      [
        hash_including('id' => @expected_record.uuid)
      ]
    )
  end
end
