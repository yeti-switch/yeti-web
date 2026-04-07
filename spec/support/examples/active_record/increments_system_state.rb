# frozen_string_literal: true

RSpec.shared_examples :increments_system_state do |key, by: 1|
  it "increments #{key} state by #{by}" do
    state = System::State.find(key)
    expect { subject }.to change { state.reload.value }.by(by)
  end
end
