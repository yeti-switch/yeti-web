# frozen_string_literal: true

RSpec.describe PartitionModel::Log do
  describe '.find_by_name' do
    subject do
      described_class.find_by_name(name)
    end

    before do
      Log::ApiLog.add_partition_for Time.parse('2018-12-02 12:00:00')
      Log::ApiLog.add_partition_for Time.parse('2019-01-15 12:00:00')
    end

    context 'first' do
      let(:name) { 'logs.api_requests_2019_01_15' }

      it 'returns correct partition' do
        expect(subject).to be_an_kind_of(described_class)
        expect(subject).to have_attributes(
          name: 'logs.api_requests_2019_01_15',
          parent_table: 'logs.api_requests',
          date_from: Date.parse('2019-01-15'),
          date_to: Date.parse('2019-01-16')
        )
      end
    end

    context 'second' do
      let(:name) { 'logs.api_requests_2018_12_02' }

      it 'returns correct partition' do
        expect(subject).to be_an_kind_of(described_class)
        expect(subject).to have_attributes(
          name: 'logs.api_requests_2018_12_02',
          parent_table: 'logs.api_requests',
          date_from: Date.parse('2018-12-02'),
          date_to: Date.parse('2018-12-03')
        )
      end
    end

    context 'invalid' do
      let(:name) { 'logs.api_requests_2007_11' }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#destroy' do
    subject do
      record.destroy
    end

    let(:logs_qty) { 5 }

    before do
      FactoryBot.create_list :api_log, logs_qty, created_at: Time.parse('2018-12-02 12:00:00')
    end
    let!(:another_logs) do
      FactoryBot.create_list :api_log, 3, created_at: Time.parse('2019-01-15 12:00:00')
    end
    let!(:record) do
      record_id = Digest::MD5.hexdigest('logs.api_requests_2018_12_02')
      described_class.find(record_id)
    end
    let!(:another_record) do
      record_id = Digest::MD5.hexdigest('logs.api_requests_2019_01_15')
      described_class.find(record_id)
    end

    it { is_expected.to eq(true) }

    it 'removes correct partition table' do
      expect { subject }.to change {
        SqlCaller::Yeti.table_exist?(record.name)
      }.from(true).to(false)

      expect(SqlCaller::Yeti.table_exist?(another_record.name)).to eq(true)
    end

    it 'removes CDRs from correct partition' do
      expect { subject }.to change { Log::ApiLog.count }.by(-logs_qty)

      another_log_ids = another_logs.map(&:id)
      expect(Log::ApiLog.where(id: another_log_ids).count).to eq(another_log_ids.size)
    end
  end
end
