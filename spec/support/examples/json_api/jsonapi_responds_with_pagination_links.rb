# frozen_string_literal: true

RSpec.shared_examples :jsonapi_responds_with_pagination_links do
  it 'has pagination' do
    subject
    expect(response_json[:links]).to match(
                                       first: be_present,
                                       last: be_present
                                     )
  end
end
