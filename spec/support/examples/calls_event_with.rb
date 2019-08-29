# frozen_string_literal: true

RSpec.shared_examples :calls_event_with do |meth, times: 1|
  let(:event_meth_arguments) { no_args }

  it "calls Event with #{meth}" do
    expect(Event).to receive(meth).with(event_meth_arguments).exactly(times)
    subject
  end
end
