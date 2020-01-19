# frozen_string_literal: true

# :errors - Hash or Array of Hashes [required]
# :status - response status code [default 422]
RSpec.shared_examples :returns_json_api_errors do |errors:, status: 422|
  it "returns json api errors with status #{status}" do
    subject
    expect(response.status).to eq(status)
    expect(response_json).to match(
      hash_including(
        errors: match_array(
          Array.wrap(errors).map { |error| hash_including(error) }
        )
      )
    )
  end
end
