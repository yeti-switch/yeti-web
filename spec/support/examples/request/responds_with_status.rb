RSpec.shared_examples :responds_with_status do |status|
  it "responds with status #{status}" do
    subject
    expect(response.status).to(
        eq(status),
        "expect response.status to eq #{status}, but got #{response.status}\n#{response.body}"
    )
  end
end
