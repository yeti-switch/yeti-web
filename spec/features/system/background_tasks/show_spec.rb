# frozen_string_literal: true

RSpec.describe 'Show System Background Task', type: :feature do
  subject do
    visit background_task_path(background_task.id)
  end

  include_context :login_as_admin

  let!(:background_task) do
    active_job = with_real_active_job_adapter do
      active_job_class.perform_later(*active_job_args)
    end
    delayed_job_id = active_job.provider_job_id
    BackgroundTask.find(delayed_job_id)
  end

  shared_examples :responds_successfully do
    it 'responds successfully' do
      subject
      expect(page).to have_attribute_row('ID', exact_text: background_task.id)
      expect(page).to have_attribute_row('name', exact_text: active_job_class.name)
    end
  end

  context 'with Worker::CdrExportJob' do
    let(:active_job_class) { Worker::CdrExportJob }
    let(:active_job_args) { [123] }

    include_examples :responds_successfully
  end

  context 'with Worker::FillInvoiceJob' do
    let(:active_job_class) { Worker::FillInvoiceJob }
    let(:active_job_args) { [123] }

    include_examples :responds_successfully
  end

  context 'with Worker::PingCallbackUrlJob' do
    let(:active_job_class) { Worker::PingCallbackUrlJob }
    let(:active_job_args) { ['example.com', {}] }

    include_examples :responds_successfully
  end

  context 'with Worker::RemoveCdrExportFileJob' do
    let(:active_job_class) { Worker::RemoveCdrExportFileJob }
    let(:active_job_args) { [123] }

    include_examples :responds_successfully
  end

  context 'with Worker::SendEmailLogJob' do
    let(:active_job_class) { Worker::SendEmailLogJob }
    let(:active_job_args) { [123] }

    include_examples :responds_successfully
  end

  context 'with Worker::CustomCdrReportJob' do
    let(:active_job_class) { Worker::CustomCdrReportJob }
    let(:active_job_args) { [123] }

    include_examples :responds_successfully
  end

  context 'with Worker::GenerateReportDataJob' do
    let(:active_job_class) { Worker::GenerateReportDataJob }
    let(:active_job_args) { ['QweAsd', 123] }

    include_examples :responds_successfully
  end
end
