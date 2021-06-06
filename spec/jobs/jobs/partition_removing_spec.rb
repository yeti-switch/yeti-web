# frozen_string_literal: true

RSpec.describe Jobs::PartitionRemoving, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  before do
    expect(job).to receive(:partition_remove_delay).exactly(4).times.and_return(
      'cdr.cdr' => 3,
      'logs.api_requests' => 5
    )

    Cdr::Cdr.add_partition_for Date.parse('2019-01-02')
    Cdr::Cdr.add_partition_for Time.now.utc
    Cdr::Cdr.add_partition_for 1.month.from_now.utc
    Cdr::Cdr.add_partition_for Date.parse('2018-12-02')
    Cdr::Cdr.add_partition_for Date.parse('2018-11-02')
    Cdr::Cdr.add_partition_for Date.parse('2018-10-02')

    Log::ApiLog.add_partition_for Date.parse('2019-01-02')
    Log::ApiLog.add_partition_for Time.now.utc
    Log::ApiLog.add_partition_for 1.day.from_now.utc
    Log::ApiLog.add_partition_for 1.day.ago.utc
    Log::ApiLog.add_partition_for 2.days.ago.utc
    Log::ApiLog.add_partition_for 3.days.ago.utc
    Log::ApiLog.add_partition_for 4.days.ago.utc
    Log::ApiLog.add_partition_for Time.parse('2018-10-02 00:00:00 UTC')
  end

  it 'removes correct cdr.cdr partition table' do
    expect { subject }.to change {
      SqlCaller::Cdr.table_exist?('cdr.cdr_2018_10')
    }.from(true).to(false)
  end

  it 'does not remove any other cdr partitions' do
    expect { subject }.to change { PartitionModel::Cdr.all.size }.by(-1)
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
