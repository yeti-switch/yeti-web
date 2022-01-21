# frozen_string_literal: true

RSpec.shared_examples :raises_exception do |klass, msg = nil|
  let(:expected_exception_capture_context) { anything }

  it "raises <#{klass}>: #{msg}" do
    expect { subject }.to raise_error(klass, msg) do |error|
      expect(CaptureError.retrieve_exception_context(error)).to match(expected_exception_capture_context)
    end
  end
end
