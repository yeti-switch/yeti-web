# frozen_string_literal: true

RSpec.describe Worker::SendHttpJob, '#perform_now' do
  subject do
    described_class.new(*job_args).perform_now
  end

  let(:job_args) { [url, content_type, body] }

  let(:url) { 'https://example.com/callback' }
  let(:content_type) { HttpSender::CONTENT_TYPE_JSON }
  let(:body) { '{"foo":"bar"}' }

  it 'calls HttpSender#send_request' do
    stub = instance_double(HttpSender)
    expect(HttpSender).to receive(:new).with(url: url, content_type: content_type, body: body).once.and_return(stub)
    expect(stub).to receive(:send_request).with(no_args).once
    expect { subject }.to_not raise_error
  end
end
