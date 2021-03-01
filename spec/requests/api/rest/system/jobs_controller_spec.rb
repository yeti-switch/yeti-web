# frozen_string_literal: true

RSpec.describe Api::Rest::System::JobsController, 'PUT /api/rest/system/jobs/:id/run' do
  subject do
    put "/api/rest/system/jobs/#{job_type}/run"
  end

  let!(:node) do
    create(:node)
  end

  context 'with successful execution' do
    before do
      expect(BaseJob).to receive(:launch!).with(job_type).once.and_call_original
      expect_any_instance_of("Jobs::#{job_type}".constantize).to receive(:execute).once.and_call_original
    end

    context 'when type is EventProcessor' do
      let(:job_type) { 'EventProcessor' }

      include_examples :responds_with_status, 204
    end
  end

  context 'when raise exception' do
    let(:job_type) { 'RspecInvalidType' }
    before do
      expect(BaseJob).to receive(:launch!).with(job_type).once.and_raise(StandardError, 'test error')
    end

    include_examples :raises_exception, StandardError, 'test error'
    include_examples :captures_error, safe: true do
      let(:capture_error_context) do
        {
          user: nil,
          tags: {
            action_name: 'run',
            controller_name: 'api/rest/system/jobs',
            job_class: job_type,
            request_id: be_present
          },
          extra: {},
          request_env: be_present
        }
      end
    end
  end
end
