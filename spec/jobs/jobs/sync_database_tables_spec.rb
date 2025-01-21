# frozen_string_literal: true

RSpec.describe Jobs::SyncDatabaseTables, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }

  before do
    # clear records from fixtures during this test
    System::NetworkPrefix.delete_all
    System::Network.delete_all
    System::Country.delete_all

    # create required qty of records
    FactoryBot.create_list(:country_uniq, record_count)
    FactoryBot.create_list(:network_uniq, record_count)
    FactoryBot.create_list(:network_prefix, record_count)
  end

  shared_examples 'sync database' do
    it 'should sync tables between databases' do
      expect { subject }.to change {
        [
          Cdr::Country.count,
          Cdr::Network.count,
          Cdr::NetworkPrefix.count
        ]
      }.from(
        [0, 0, 0]
      ).to(
        [
          record_count,
          record_count,
          record_count
        ]
      )
    end
  end

  context 'with 200 records' do
    let(:record_count) { 200 }

    include_examples 'sync database'
  end

  context 'with 1000 records' do
    let(:record_count) { 1000 }

    include_examples 'sync database'
  end
end
