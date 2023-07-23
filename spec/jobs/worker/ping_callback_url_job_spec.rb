# frozen_string_literal: true

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

    include_examples :captures_error, safe: true do
      let(:capture_error_exception_class) { Worker::PingCallbackUrlJob::TryAgainError }
      let(:capture_error_user) { nil }
      let(:capture_error_tags) do
        {
          delayed_job_queue: 'ping_callback_url',
          delayed_job_id: nil,
          active_job_class: described_class.to_s,
          active_job_id: be_present
        }
      end
      let(:capture_error_extra) do
        {
          active_job_class: described_class.to_s,
          active_job_id: be_present,
          arguments: [callback_url, params],
          scheduled_at: nil,
          delayed_job: {
            id: nil,
            priority: nil,
            attempts: nil,
            run_at: nil,
            locked_at: nil,
            locked_by: nil,
            queue: nil,
            created_at: nil
          }
        }
      end
    end
  end
end
