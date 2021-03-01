# frozen_string_literal: true

RSpec.shared_examples :captures_error do |safe: false, request: false|
  let(:capture_error_context) do
    { tags: a_kind_of(Hash), extra: a_kind_of(Hash), request_env: request ? be_present : nil }
  end
  let(:capture_error_exception_class) { StandardError }
  let(:capture_error_exception) { a_kind_of(capture_error_exception_class) }

  it 'captures exception' do
    expect(CaptureError).to receive(:capture) do |error, options|
      expect(error).to match(capture_error_exception)
      expect(options[:user]).to match(capture_error_context[:user])
      expect(options[:tags]).to match(capture_error_context[:tags])
      expect(options[:extra]).to match(capture_error_context[:extra])
      expect(options[:request_env]).to match(capture_error_context[:request_env])
    end
    safe ? safe_subject : subject
  end
end
