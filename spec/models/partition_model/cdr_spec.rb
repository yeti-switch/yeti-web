# frozen_string_literal: true

RSpec.describe PartitionModel::Cdr do
  describe '.find_by_name' do
    subject do
      described_class.find_by_name(name)
    end

    before do
      Cdr::Cdr.add_partition_for Date.parse('2018-12-02')
      Cdr::Cdr.add_partition_for Date.parse('2019-01-15')
    end

    context 'first' do
      let(:name) { 'cdr.cdr_2019_01' }

      it 'returns correct partition' do
        expect(subject).to be_an_kind_of(described_class)
        expect(subject).to have_attributes(
          name: 'cdr.cdr_2019_01',
          parent_table: 'cdr.cdr',
          date_from: Date.parse('2019-01-01'),
          date_to: Date.parse('2019-02-01')
        )
      end
    end

    context 'second' do
      let(:name) { 'cdr.cdr_2018_12' }

      it 'returns correct partition' do
        expect(subject).to be_an_kind_of(described_class)
        expect(subject).to have_attributes(
          name: 'cdr.cdr_2018_12',
          parent_table: 'cdr.cdr',
          date_from: Date.parse('2018-12-01'),
          date_to: Date.parse('2019-01-01')
        )
      end
    end

    context 'invalid' do
      let(:name) { 'cdr.cdr_2007_11' }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#destroy' do
    subject do
      record.destroy
    end

    let(:cdrs_qty) { 5 }

    before do
      # Cdr::Cdr.add_partition_for Date.parse('2018-12-02')
      # Cdr::Cdr.add_partition_for Date.parse('2019-01-15')
      FactoryGirl.create_list :cdr, cdrs_qty, time_start: Date.parse('2018-12-02')
    end
    let!(:another_cdrs) do
      FactoryGirl.create_list :cdr, 3, time_start: Date.parse('2019-01-15')
    end
    let!(:record) do
      record_id = Digest::MD5.hexdigest('cdr.cdr_2018_12')
      PartitionModel::Cdr.find(record_id)
    end
    let!(:another_record) do
      record_id = Digest::MD5.hexdigest('cdr.cdr_2019_01')
      PartitionModel::Cdr.find(record_id)
    end

    it { is_expected.to eq(true) }

    it 'removes correct partition table' do
      expect { subject }.to change {
        SqlCaller::Cdr.table_exist?(record.name)
      }.from(true).to(false)

      expect(SqlCaller::Cdr.table_exist?(another_record.name)).to eq(true)
    end

    it 'removes CDRs from correct partition' do
      expect { subject }.to change { Cdr::Cdr.count }.by(-cdrs_qty)

      another_cdrs_ids = another_cdrs.map(&:id)
      expect(Cdr::Cdr.where(id: another_cdrs_ids).count).to eq(another_cdrs_ids.size)
    end
  end
end
