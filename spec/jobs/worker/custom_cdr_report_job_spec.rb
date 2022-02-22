# frozen_string_literal: true

RSpec.describe Worker::CustomCdrReportJob, '#perform_now' do
  subject do
    described_class.new(*job_args).perform_now
  end

  let(:job_args) { [report.id] }

  let!(:report) { FactoryBot.create(:custom_cdr) }

  it 'calls BillingInvoice::Fill' do
    expect(CustomCdrReport::GenerateData).to receive(:call).with(report: report).once.and_call_original
    expect { subject }.to_not raise_error
  end

  context 'when id is invalid' do
    let(:job_args) { [report.id + 1] }

    it 'calls BillingInvoice::Fill' do
      expect(CustomCdrReport::GenerateData).to_not receive(:call)
      expect { subject }.to_not raise_error
    end
  end
end
