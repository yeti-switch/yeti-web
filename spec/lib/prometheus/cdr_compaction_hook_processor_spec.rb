# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/cdr_compaction_hook_processor')

RSpec.describe CdrCompactionHookProcessor do
  let(:prometheus_client) { instance_double(PrometheusExporter::Client) }

  before do
    allow(PrometheusExporter::Client).to receive(:default).and_return(prometheus_client)
    expect(Thread).to receive(:new).and_yield
  end

  describe '.collect_executions_metric' do
    subject { CdrCompactionHookProcessor.collect_executions_metric }

    it 'sends a bare counter, without any labels' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_cdr_compaction_hook', executions: 1 }
      ).once
      subject
    end
  end

  describe '.collect_success_metric' do
    subject { CdrCompactionHookProcessor.collect_success_metric }

    it 'sends a bare counter, without any labels' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_cdr_compaction_hook', success: 1 }
      ).once
      subject
    end
  end

  describe '.collect_errors_metric' do
    subject { CdrCompactionHookProcessor.collect_errors_metric }

    it 'sends a bare counter, without any labels' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_cdr_compaction_hook', errors: 1 }
      ).once
      subject
    end
  end

  describe '.collect_duration_metric' do
    subject { CdrCompactionHookProcessor.collect_duration_metric(13) }

    it 'sends a bare counter, without any labels' do
      expect(prometheus_client).to receive(:send_json).with(
        { type: 'yeti_cdr_compaction_hook', duration: 13 }
      ).once
      subject
    end
  end
end
