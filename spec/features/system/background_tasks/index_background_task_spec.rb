# frozen_string_literal: true

RSpec.describe 'Index System Background Tasks', type: :feature do
  subject do
    visit background_tasks_path
  end

  include_context :login_as_admin

  let!(:background_tasks) do
    active_jobs = with_real_active_job_adapter do
      [
        Worker::CdrExportJob.perform_later(123),
        Worker::FillInvoiceJob.perform_later(123),
        Worker::PingCallbackUrlJob.perform_later('example.com', {}),
        Worker::RemoveCdrExportFileJob.perform_later(123),
        Worker::SendEmailLogJob.perform_later(123),
        Worker::CustomCdrReportJob.perform_later(123),
        Worker::GenerateReportDataJob.perform_later('QweAsd', 123)
      ]
    end
    delayed_job_ids = active_jobs.map(&:provider_job_id)
    BackgroundTask.find(*delayed_job_ids)
  end

  it 'n+1 checks' do
    subject
    background_tasks.each do |background_task|
      expect(page).to have_css('.resource_id_link', text: background_task.id)
    end
  end
end
