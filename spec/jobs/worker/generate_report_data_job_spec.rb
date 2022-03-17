# frozen_string_literal: true

RSpec.describe Worker::GenerateReportDataJob, '#perform_now' do
  subject do
    described_class.new(*job_args).perform_now
  end

  shared_examples :generates_report_data do
    it 'generates report data' do
      expect(service_class).to receive(:call).with(report: report).once.and_call_original
      expect { subject }.to_not raise_error
    end
  end

  let(:job_args) { [report_name, report.id] }
  let(:report_name) { report.class.name.demodulize }
  let(:service_class) { "GenerateReportData::#{report_name}".constantize }
  let!(:report) { FactoryBot.create(:custom_cdr) }

  include_examples :generates_report_data

  context 'with IntervalCdr report' do
    let!(:report) { FactoryBot.create(:interval_cdr) }

    include_examples :generates_report_data
  end

  context 'with CustomerTraffic report' do
    let!(:report) { FactoryBot.create(:customer_traffic) }

    include_examples :generates_report_data
  end

  context 'with VendorTraffic report' do
    let!(:report) { FactoryBot.create(:vendor_traffic) }

    include_examples :generates_report_data
  end

  context 'when id is invalid' do
    let(:job_args) { [report_name, report.id + 1] }

    it 'does not generate report data' do
      expect(service_class).to_not receive(:call)
      expect { subject }.to_not raise_error
    end
  end

  context 'when report_name is invalid' do
    let(:job_args) { ['InvalidReport', report.id + 1] }

    it 'raises NameError' do
      expect(GenerateReportData::CustomCdr).to_not receive(:call)
      expect { subject }.to raise_error(NameError)
    end
  end
end
