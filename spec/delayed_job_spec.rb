# frozen_string_literal: true

RSpec.describe Delayed::Job do
  describe '.ready_to_run' do
    subject do
      Delayed::Job.ready_to_run('rspec', Delayed::Worker.max_run_time)
    end

    shared_examples :includes_delayed_jobs do
      it 'includes correct delayed jobs' do
        expect(subject.count).to eq expected_delayed_jobs.size
        expected_delayed_jobs.each do |delayed_job|
          expect(subject).to include(delayed_job)
        end
      end
    end

    let!(:regular_delayed_jobs) do
      klasses = [
        Worker::CdrExportJob,
        Worker::FillInvoiceJob,
        Worker::PingCallbackUrlJob,
        Worker::RemoveCdrExportFileJob,
        Worker::SendEmailLogJob,
        Worker::GenerateReportDataJob
      ]
      active_jobs = with_dj_queue_adapter(*klasses) do
        [
          Worker::CdrExportJob.perform_later(123),
          Worker::CdrExportJob.perform_later(124),
          Worker::FillInvoiceJob.perform_later(123),
          Worker::FillInvoiceJob.perform_later(124),
          Worker::PingCallbackUrlJob.perform_later('example.com', {}),
          Worker::PingCallbackUrlJob.perform_later('test.com', {}),
          Worker::RemoveCdrExportFileJob.perform_later(123),
          Worker::RemoveCdrExportFileJob.perform_later(124),
          Worker::SendEmailLogJob.perform_later(123),
          Worker::SendEmailLogJob.perform_later(124),
          Worker::GenerateReportDataJob.perform_later('QweAsd', 123),
          Worker::GenerateReportDataJob.perform_later('ZxcUio', 124)
        ]
      end
      delayed_job_ids = active_jobs.map(&:provider_job_id)
      Delayed::Job.find(*delayed_job_ids)
    end
    let!(:custom_cdr_report_job) do
      active_job = with_dj_queue_adapter(Worker::CustomCdrReportJob) do
        Worker::CustomCdrReportJob.perform_later(123)
      end
      Delayed::Job.find(active_job.provider_job_id)
    end

    include_examples :includes_delayed_jobs do
      let(:expected_delayed_jobs) { regular_delayed_jobs + [custom_cdr_report_job] }
    end

    context 'when Worker::CustomCdrReportJob were locked now' do
      before do
        custom_cdr_report_job.update!(locked_at: 1.second.ago, locked_by: 'some')
      end

      include_examples :includes_delayed_jobs do
        let(:expected_delayed_jobs) { regular_delayed_jobs }
      end
    end

    context 'when Worker::CustomCdrReportJob were locked more than Delayed::Worker.max_run_time ago' do
      before do
        locked_at = Delayed::Worker.max_run_time.ago - 1.second
        custom_cdr_report_job.update!(locked_at: locked_at, locked_by: 'some')
      end

      include_examples :includes_delayed_jobs do
        let(:expected_delayed_jobs) { regular_delayed_jobs + [custom_cdr_report_job] }
      end
    end

    context 'when 2 Worker::CustomCdrReportJob are enqueued' do
      let!(:old_custom_cdr_report_job) do
        active_job = with_dj_queue_adapter(Worker::CustomCdrReportJob) do
          Worker::CustomCdrReportJob.perform_later(122)
        end
        Delayed::Job.find(active_job.provider_job_id)
      end

      include_examples :includes_delayed_jobs do
        let(:expected_delayed_jobs) { regular_delayed_jobs + [custom_cdr_report_job, old_custom_cdr_report_job] }
      end

      context 'when one of Worker::CustomCdrReportJob were locked now' do
        before do
          old_custom_cdr_report_job.update!(locked_at: 1.second.ago, locked_by: 'some')
        end

        include_examples :includes_delayed_jobs do
          let(:expected_delayed_jobs) { regular_delayed_jobs }
        end
      end

      context 'when one of Worker::CustomCdrReportJob were locked more than Delayed::Worker.max_run_time ago' do
        before do
          locked_at = Delayed::Worker.max_run_time.ago - 1.second
          old_custom_cdr_report_job.update!(locked_at: locked_at, locked_by: 'some')
        end

        include_examples :includes_delayed_jobs do
          let(:expected_delayed_jobs) { regular_delayed_jobs + [custom_cdr_report_job, old_custom_cdr_report_job] }
        end
      end
    end

    context 'when 3 Worker::CustomCdrReportJob are enqueued' do
      let!(:old_custom_cdr_report_job) do
        active_job = with_dj_queue_adapter(Worker::CustomCdrReportJob) do
          Worker::CustomCdrReportJob.perform_later(122)
        end
        Delayed::Job.find(active_job.provider_job_id)
      end
      let!(:very_old_custom_cdr_report_job) do
        active_job = with_dj_queue_adapter(Worker::CustomCdrReportJob) do
          Worker::CustomCdrReportJob.perform_later(121)
        end
        Delayed::Job.find(active_job.provider_job_id)
      end

      include_examples :includes_delayed_jobs do
        let(:expected_delayed_jobs) do
          regular_delayed_jobs + [custom_cdr_report_job, old_custom_cdr_report_job, very_old_custom_cdr_report_job]
        end
      end

      context 'when one of Worker::CustomCdrReportJob were locked now' do
        before do
          old_custom_cdr_report_job.update!(locked_at: 1.second.ago, locked_by: 'some')
        end

        include_examples :includes_delayed_jobs do
          let(:expected_delayed_jobs) { regular_delayed_jobs }
        end
      end

      context 'when one of Worker::CustomCdrReportJob were locked more than Delayed::Worker.max_run_time ago' do
        before do
          locked_at = Delayed::Worker.max_run_time.ago - 1.second
          old_custom_cdr_report_job.update!(locked_at: locked_at, locked_by: 'some')
        end

        include_examples :includes_delayed_jobs do
          let(:expected_delayed_jobs) do
            regular_delayed_jobs + [custom_cdr_report_job, old_custom_cdr_report_job, very_old_custom_cdr_report_job]
          end
        end
      end
    end
  end

  describe 'enqueue' do
    subject do
      active_job = with_dj_queue_adapter(active_job_class) do
        active_job_class.perform_later(*active_job_args)
      end
      Delayed::Job.find(active_job.provider_job_id)
    end

    shared_examples :creates_delayed_job do
      it 'creates delayed job' do
        expect { subject }.to change { Delayed::Job.count }.by(1)
        delayed_job = Delayed::Job.last!
        expect(delayed_job.payload_object.job_data['job_class']).to eq active_job_class.to_s
        expect(delayed_job).to have_attributes(
                                 unique_name: expected_unique_name
                               )
      end
    end

    context 'with Worker::CustomCdrReportJob' do
      let(:active_job_class) { Worker::CustomCdrReportJob }
      let(:active_job_args) { [123] }

      include_examples :creates_delayed_job do
        let(:expected_unique_name) { active_job_class.to_s }
      end
    end

    context 'with Worker::CdrExportJob' do
      let(:active_job_class) { Worker::CdrExportJob }
      let(:active_job_args) { [123] }

      include_examples :creates_delayed_job do
        let(:expected_unique_name) { nil }
      end
    end

    context 'with Worker::FillInvoiceJob' do
      let(:active_job_class) { Worker::FillInvoiceJob }
      let(:active_job_args) { [123] }

      include_examples :creates_delayed_job do
        let(:expected_unique_name) { nil }
      end
    end

    context 'with Worker::PingCallbackUrlJob' do
      let(:active_job_class) { Worker::PingCallbackUrlJob }
      let(:active_job_args) { ['example.com', {}] }

      include_examples :creates_delayed_job do
        let(:expected_unique_name) { nil }
      end
    end

    context 'with Worker::RemoveCdrExportFileJob' do
      let(:active_job_class) { Worker::RemoveCdrExportFileJob }
      let(:active_job_args) { [123] }

      include_examples :creates_delayed_job do
        let(:expected_unique_name) { nil }
      end
    end

    context 'with Worker::SendEmailLogJob' do
      let(:active_job_class) { Worker::SendEmailLogJob }
      let(:active_job_args) { [123] }

      include_examples :creates_delayed_job do
        let(:expected_unique_name) { nil }
      end
    end
  end
end
