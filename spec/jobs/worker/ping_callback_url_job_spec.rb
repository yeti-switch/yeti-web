# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Worker::PingCallbackUrlJob, type: :job do
  subject do
    described_class.perform_now(callback_url, params)
  end
  let(:params) do
    {
      export_id: '123',
      status: 'Completed'
    }
  end
  let(:callback_url) do
    'http://example.com/notify'
  end

  it 'GET request to callback url with specified params should be performed' do
    mock = stub_request(:get, callback_url)
           .with(body: params)
           .to_return(status: 200)
    expect { subject }.not_to raise_error
    expect(mock).to have_been_requested.once
  end

  context 'when callback url is unreachable' do
    before do
      @mock = stub_request(:get, callback_url)
              .with(body: params)
              .to_return(status: 400)
    end

    it 'TryAgainError should be raised' do
      expect { subject }.to raise_error(Worker::PingCallbackUrlJob::TryAgainError)
      expect(@mock).to have_been_requested.once
    end
  end
end
