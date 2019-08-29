# frozen_string_literal: true

RSpec.shared_examples :does_not_call_event_with do |meth|
  it "does not call Event with #{meth}" do
    expect(Event).to_not receive(meth)
    subject
  end
end
