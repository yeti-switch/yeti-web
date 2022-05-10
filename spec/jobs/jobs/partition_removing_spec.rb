# frozen_string_literal: true

RSpec.describe Jobs::PartitionRemoving, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  before do
    expect(job).to receive(:partition_remove_delay).exactly(6).times.and_return(
      'cdr.cdr' => '3 days',
      'auth_log.auth_log' => '3 days',
      'rtp_statistics.rx_streams' => '3 days',
      'rtp_statistics.tx_streams' => '3 days',
      'logs.api_requests' => '5 days'
    )
    PartitionModel::Cdr.to_a.each(&:destroy!)
  end

  context 'when there are old Cdr::Cdr partitions' do
    before do
      Cdr::Cdr.add_partition_for Time.now.utc
      Cdr::Cdr.add_partition_for 1.day.from_now.utc
      Cdr::Cdr.add_partition_for 1.day.ago.utc
      Cdr::Cdr.add_partition_for 2.days.ago.utc
      Cdr::Cdr.add_partition_for 3.days.ago.utc
      Cdr::Cdr.add_partition_for 4.days.ago.utc
      Cdr::Cdr.add_partition_for 5.days.ago.utc
    end

    it 'removes correct cdr.cdr partition table' do
      date = 5.days.ago.utc.to_date
      expect { subject }.to change {
        SqlCaller::Cdr.table_exist?("cdr.cdr_#{date.strftime('%Y_%m_%d')}")
      }.from(true).to(false)
    end

    it 'does not remove any other cdr partitions' do
      expect { subject }.to change { PartitionModel::Cdr.all.size }.by(-1)
    end
  end

  context 'when there are no old Cdr::Cdr partitions' do
    before do
      Cdr::Cdr.add_partition_for Time.now.utc
      Cdr::Cdr.add_partition_for 1.day.from_now.utc
      Cdr::Cdr.add_partition_for 1.day.ago.utc
      Cdr::Cdr.add_partition_for 2.days.ago.utc
      Cdr::Cdr.add_partition_for 3.days.ago.utc
    end

    it 'does not remove last cdr.cdr partition table' do
      date = 3.days.ago.utc.to_date
      expect { subject }.not_to change {
        SqlCaller::Cdr.table_exist?("cdr.cdr_#{date.strftime('%Y_%m_%d')}")
      }.from(true)
    end

    it 'does not remove any other cdr partitions' do
      expect { subject }.not_to change { PartitionModel::Cdr.all.size }
    end
  end

  context 'when there are old Log::ApiLog partitions' do
    before do
      Log::ApiLog.add_partition_for Date.parse('2019-01-02')
      Log::ApiLog.add_partition_for Time.now.utc
      Log::ApiLog.add_partition_for 1.day.from_now.utc
      Log::ApiLog.add_partition_for 1.day.ago.utc
      Log::ApiLog.add_partition_for 2.days.ago.utc
      Log::ApiLog.add_partition_for 3.days.ago.utc
      Log::ApiLog.add_partition_for 4.days.ago.utc
      Log::ApiLog.add_partition_for Time.parse('2018-10-02 00:00:00 UTC')
    end

    it 'removes correct logs.api_requests partition table' do
      expect { subject }.to change {
        SqlCaller::Yeti.table_exist?('logs.api_requests_2018_10_02')
      }.from(true).to(false)
    end

    it 'does not remove any other yeti partitions' do
      expect { subject }.to change { PartitionModel::Log.all.size }.by(-1)
    end
  end
end
