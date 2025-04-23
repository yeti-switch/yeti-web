# frozen_string_literal: true

RSpec.shared_examples :increments_customers_auth_state do |by: 1|
  it "increments customers_auth state by #{by}" do
    state = System::State.find(CustomersAuth.state_names[0])
    expect { subject }.to change { state.reload.value }.by(by)
  end
end
