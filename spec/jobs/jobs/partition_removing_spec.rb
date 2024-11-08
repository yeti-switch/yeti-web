# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/partition_remove_hook_processor')

RSpec.describe Jobs::PartitionRemoving, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }
  let(:prometheus_enabled) { false }

  before do
    expect(job).to receive(:partition_remove_delay).exactly(5).times.and_return(
      'cdr.cdr' => '3 days',
      'auth_log.auth_log' => '3 days',
      'rtp_statistics.rx_streams' => '3 days',
      'rtp_statistics.tx_streams' => '3 days',
      'logs.api_requests' => '5 days'
    )
    PartitionModel::Cdr.to_a.each(&:destroy!)

    allow(PrometheusConfig).to receive(:enabled?).and_return(prometheus_enabled)
  end

  shared_examples :should_not_collect_prometheus_metrics do
    it 'should NOT collect Prometheus metrics' do
      expect(PartitionRemoveHookProcessor).to_not receive(:collect)
      subject
    end
  end

  context 'without partition_remove_hook' do
    context 'when there are old Cdr::Cdr partitions' do
      before do
        Cdr::Cdr.add_partition_for Time.current
        Cdr::Cdr.add_partition_for 1.day.from_now
        Cdr::Cdr.add_partition_for 1.day.ago
        Cdr::Cdr.add_partition_for 2.days.ago
        Cdr::Cdr.add_partition_for 3.days.ago
        Cdr::Cdr.add_partition_for 4.days.ago
        Cdr::Cdr.add_partition_for 5.days.ago
      end

      include_examples :should_not_collect_prometheus_metrics

      it 'removes correct cdr.cdr partition table' do
        date = 5.days.ago.to_date
        expect { subject }.to change {
          SqlCaller::Cdr.table_exist?("cdr.cdr_#{date.strftime('%Y_%m_%d')}")
        }.from(true).to(false)
      end

      it 'does not remove any other cdr partitions' do
        expect { subject }.to change { PartitionModel::Cdr.all.size }.by(-1)
      end

      context 'when Prometheus is enabled' do
        let(:prometheus_enabled) { true }

        include_examples :should_not_collect_prometheus_metrics
      end
    end

    context 'when there are no old Cdr::Cdr partitions' do
      before do
        Cdr::Cdr.add_partition_for Time.current
        Cdr::Cdr.add_partition_for 1.day.from_now
        Cdr::Cdr.add_partition_for 1.day.ago
        Cdr::Cdr.add_partition_for 2.days.ago
        Cdr::Cdr.add_partition_for 3.days.ago
      end

      include_examples :should_not_collect_prometheus_metrics

      it 'does not remove last cdr.cdr partition table' do
        date = 3.days.ago.to_date
        expect { subject }.not_to change {
          SqlCaller::Cdr.table_exist?("cdr.cdr_#{date.strftime('%Y_%m_%d')}")
        }.from(true)
      end

      it 'does not remove any other cdr partitions' do
        expect { subject }.not_to change { PartitionModel::Cdr.all.size }
      end

      context 'when Prometheus is enabled' do
        let(:prometheus_enabled) { true }

        include_examples :should_not_collect_prometheus_metrics
      end
    end

    context 'when there are old Log::ApiLog partitions' do
      before do
        Log::ApiLog.add_partition_for Date.parse('2019-01-02')
        Log::ApiLog.add_partition_for Time.current
        Log::ApiLog.add_partition_for 1.day.from_now
        Log::ApiLog.add_partition_for 1.day.ago
        Log::ApiLog.add_partition_for 2.days.ago
        Log::ApiLog.add_partition_for 3.days.ago
        Log::ApiLog.add_partition_for 4.days.ago
        Log::ApiLog.add_partition_for Time.parse('2018-10-02 00:00:00 UTC')
      end

      include_examples :should_not_collect_prometheus_metrics

      it 'removes correct logs.api_requests partition table' do
        expect { subject }.to change {
          SqlCaller::Yeti.table_exist?('logs.api_requests_2018_10_02')
        }.from(true).to(false)
      end

      it 'does not remove any other yeti partitions' do
        expect { subject }.to change { PartitionModel::Log.all.size }.by(-1)
      end

      context 'when Prometheus is enabled' do
        let(:prometheus_enabled) { true }

        include_examples :should_not_collect_prometheus_metrics
      end
    end
  end

  context 'with partition_remove_hook' do
    let(:hook_value) { 'echo' }

    before do
      Cdr::Cdr.add_partition_for Time.current
      Cdr::Cdr.add_partition_for 1.day.from_now
      Cdr::Cdr.add_partition_for 1.day.ago
      Cdr::Cdr.add_partition_for 2.days.ago
      Cdr::Cdr.add_partition_for 3.days.ago
      Cdr::Cdr.add_partition_for 4.days.ago
      Cdr::Cdr.add_partition_for 5.days.ago

      allow(YetiConfig).to receive(:partition_remove_hook).and_return(hook_value)
    end

    shared_examples :should_drop_partition do
      it 'shoudl drop correct cdr.cdr partition table' do
        expect { subject }.to change {
          SqlCaller::Cdr.table_exist?("cdr.cdr_#{5.days.ago.to_date.strftime('%Y_%m_%d')}")
        }.from(true).to(false)
      end
    end

    context 'when there are old Cdr::Cdr partitions' do
      include_examples :should_drop_partition
      include_examples :should_not_collect_prometheus_metrics

      context 'when Prometheus is enabled' do
        let(:prometheus_enabled) { true }

        context 'when hook successful' do
          include_examples :should_drop_partition

          it 'should collect Prometheus metrics' do
            expect(PartitionRemoveHookProcessor).to receive(:collect).with(executions: 1)
            expect(PartitionRemoveHookProcessor).to receive(:collect).with(duration: be_present)
            subject
          end
        end

        context 'when hook unsuccessful' do
          let(:hook_value) { 'false' }

          it 'should NOT drop partition' do
            expect { subject }.not_to change { PartitionModel::Cdr.all.size }
          end

          it 'should collect Prometheus metrics' do
            expect(PartitionRemoveHookProcessor).to receive(:collect).with(executions: 1)
            expect(PartitionRemoveHookProcessor).to receive(:collect).with(duration: be_present)
            expect(PartitionRemoveHookProcessor).to receive(:collect).with(errors: 1)
            subject
          end
        end
      end
    end
  end
end
