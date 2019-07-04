# frozen_string_literal: true

RSpec.describe Jobs::PartitionRemoving do
  describe '#execute' do
    subject do
      job.execute
    end

    let(:job) { described_class.first! }
    before do
      expect(job).to receive(:partition_remove_delay).exactly(3).times.and_return(
        'cdr.cdr' => 3
      )

      Cdr::Cdr.add_partition_for Date.parse('2019-01-02')
      Cdr::Cdr.add_partition_for Time.now.utc
      Cdr::Cdr.add_partition_for 1.month.from_now.utc
      Cdr::Cdr.add_partition_for Date.parse('2018-12-02')
      Cdr::Cdr.add_partition_for Date.parse('2018-11-02')
      Cdr::Cdr.add_partition_for Date.parse('2018-10-02')
    end

    it 'removes correct partition table' do
      expect { subject }.to change {
        SqlCaller::Cdr.table_exist?('cdr.cdr_2018_10')
      }.from(true).to(false)
    end

    it 'does not remove any other partitions' do
      expect { subject }.to change { PartitionModel::Cdr.all.size }.by(-1)
    end
  end
end
