# frozen_string_literal: true

RSpec.shared_examples :increments_customers_auth_state_seq do |by: 1|
  it "increments customers_auth_state_seq by #{by}" do
    old_val = CustomersAuth.state_sequence
    subject
    expect(CustomersAuth.state_sequence).to eq(old_val + by)
  end
end
