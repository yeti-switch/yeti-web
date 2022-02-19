# frozen_string_literal: true

RSpec.shared_examples :does_not_capture_error do |safe: false|
  let(:does_not_capture_error_subject) do
    safe ? safe_subject : subject
  end

  it 'captures exception' do
    expect(CaptureError).not_to receive(:capture)
    does_not_capture_error_subject
  end
end
