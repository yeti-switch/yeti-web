# frozen_string_literal: true

RSpec.shared_examples :responds_with_status do |status, without_body: false|
  it "responds with status #{status}" do
    subject
    expect(response.status).to(
      eq(status),
      "expect response.status to eq #{status}, but got #{response.status}\n#{response.body}"
    )
    if without_body
      expect(response.body).to(
        be_blank,
        "expect response.body to be blank, but got #{response.body.inspect}"
      )
    end
  end
end
