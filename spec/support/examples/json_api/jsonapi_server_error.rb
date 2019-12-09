# frozen_string_literal: true

shared_examples :jsonapi_server_error do
  it 'responds with server error' do
    subject
    expect(response.status).to eq(500)
    expect(response_json[:errors]).to match(
      [hash_including(detail: 'Internal Server Error')]
    )
  end
end
