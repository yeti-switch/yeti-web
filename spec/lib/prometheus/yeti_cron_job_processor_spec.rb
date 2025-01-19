# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/yeti_cron_job_processor')

RSpec.describe YetiCronJobProcessor, '.collect' do
  subject do
    described_class.collect(data)
  end

  let(:prometheus_client) { instance_double(PrometheusExporter::Client) }
  before do
    allow(PrometheusExporter::Client).to receive(:default).and_return(prometheus_client)
    expect(Thread).to receive(:new).and_yield
  end

  shared_examples :sends_correct_metric do
    it 'sends metric to prometheus' do
      expect(prometheus_client).to receive(:send_json).with(
        {
          type: 'yeti_cron_job',
          metric_labels: { pid: Process.pid },
          name: data[:name],
          success: data[:success],
          duration: data[:duration]
        }
      ).once
      subject
    end
  end

  context 'with success: true' do
    let(:data) do
      {
        name: 'TestName',
        success: true,
        duration: 123.456
      }
    end

    include_examples :sends_correct_metric
  end

  context 'with success: false' do
    let(:data) do
      {
        name: 'SomeJob',
        success: false,
        duration: 0.078
      }
    end

    include_examples :sends_correct_metric
  end
end
