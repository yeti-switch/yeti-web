require 'spec_helper'

RSpec.describe Cdr::Table, type: :model do

  def destroy_partitions
    connection = Cdr::Table.connection
    partitions = Cdr::Table.partitions
    Cdr::Table.transaction do
      connection.execute("TRUNCATE #{Cdr::Table.table_name}")
      connection.execute("DROP TABLE #{partitions.join(', ')}") if partitions.present?
      connection.execute %q{
        CREATE OR REPLACE FUNCTION cdr.cdr_i_tgf() RETURNS trigger AS $BODY$
        BEGIN
          RAISE EXCEPTION 'cdr.cdr_i_tg: time_start out of range.';
        RETURN NULL;
        END; $BODY$ LANGUAGE plpgsql;
      }
    end
  end

  describe '#add_partition' do

    subject { described_class.add_partition }

    context 'when partitions already created' do
      it 'do not raise errors' do
        expect {
          described_class.add_partition # call create partition twice
          subject
        }.not_to raise_error
      end
    end

    context 'when partitions not exists' do
      it 'create partitions successfully' do
        destroy_partitions

        expect(described_class.partitions).to be_empty # expect partition tables not exist
        expect(described_class.count).to eq(0) # expect cdr_table to be empty

        subject

        expect(described_class.partitions).not_to be_empty # expect rables to exists
        expect(described_class.count).to eq(3) # expect cdr_tables to have three correct rows
      end

      let(:time_now) { Time.now.utc }
      let(:prev_month) { time_now.prev_month }
      let(:next_month) { time_now.next_month }

      let(:out_of_bottom_bound) { 2.month.ago.utc.end_of_month }
      let(:out_of_upper_bound) { 2.months.from_now.utc.beginning_of_month }

      let(:table_name_prev) { 'cdr.cdr_' + prev_month.strftime('%Y%m') }
      let(:table_name_current) { 'cdr.cdr_' + time_now.strftime('%Y%m') }
      let(:table_name_next) { 'cdr.cdr_' + next_month.strftime('%Y%m') }

      def partition_rows_count(date:)
          Cdr::Cdr.connection.execute(
            "SELECT id FROM cdr.cdr_#{ date.strftime('%Y%m') }"
          ).to_a.count
      end

      it 'should Insert CDR to specific partitions' do
        destroy_partitions
        subject

        # out of range
        expect {
          create(:cdr, time_start: out_of_bottom_bound)
        }.to raise_error(ActiveRecord::StatementInvalid)
        expect {
          create(:cdr, time_start: out_of_upper_bound)
        }.to raise_error(ActiveRecord::StatementInvalid)

        # current month
        expect {
          create(:cdr, time_start: time_now.beginning_of_month)
        }.to change { partition_rows_count(date: time_now) }.by(1)

        expect {
          create(:cdr, time_start: time_now.end_of_month)
        }.to change { partition_rows_count(date: time_now) }.by(1)

        # prev month
        expect {
          create(:cdr, time_start: prev_month.beginning_of_month)
        }.to change { partition_rows_count(date: prev_month) }.by(1)

        expect {
          create(:cdr, time_start: prev_month.end_of_month)
        }.to change { partition_rows_count(date: prev_month) }.by(1)

        # next months
        expect {
          create(:cdr, time_start: next_month.beginning_of_month)
        }.to change { partition_rows_count(date: next_month) }.by(1)

        expect {
          create(:cdr, time_start: next_month.end_of_month)
        }.to change { partition_rows_count(date: next_month) }.by(1)
      end

      it '`sys.cdr_tables` contains information about partitions' do
        destroy_partitions
        expect(described_class.count).to eq(0)

        subject
        expect(described_class.all).to all(
          have_attributes(readable: true, writable: true, active: true)
        )
        expect(described_class.all).to match([
          have_attributes(name: table_name_prev, date_start: prev_month.beginning_of_month, date_stop: time_now.beginning_of_month),
          have_attributes(name: table_name_current, date_start: time_now.beginning_of_month, date_stop: next_month.beginning_of_month),
          have_attributes(name: table_name_next, date_start: next_month.beginning_of_month, date_stop: next_month.next_month.beginning_of_month)
        ])
      end



      class CdrPrev < Cdr::Cdr
        self.table_name = "cdr.cdr_#{ Time.now.prev_month.strftime('%Y%m') }"
      end

      class CdrCurrent < Cdr::Cdr
        self.table_name = "cdr.cdr_#{ Time.now.strftime('%Y%m') }"
      end

      class CdrNext < Cdr::Cdr
        self.table_name = "cdr.cdr_#{ Time.now.next_month.strftime('%Y%m') }"
      end

      shared_examples :test_cdr_partition_check_fail do |klass|
        it 'should fail' do
          timestamps.each do |time_start|
            expect {
              klass.create! build(:cdr, time_start: time_start).attributes
            }.to raise_error(ActiveRecord::StatementInvalid)
          end
        end
      end

      shared_examples :test_cdr_partition_check_pass do |klass|
        it 'should save' do
          timestamps.each do |time_start|
            expect {
              klass.create! build(:cdr, time_start: time_start).attributes
            }.to change { klass.count }.by(1)
          end
        end
      end

      context 'month tables constraints' do
        after(:all) { CdrPrev.delete_all }

        context 'Previous month' do
          it_behaves_like :test_cdr_partition_check_fail, CdrPrev do
            let(:timestamps) do
              [prev_month.beginning_of_month - 1.second, prev_month.end_of_month + 1.second ]
            end
          end
          it_behaves_like :test_cdr_partition_check_pass, CdrPrev do
            let(:timestamps) do
              [ out_of_bottom_bound + 1.second, prev_month.end_of_month ]
            end
          end
        end

        context 'Current month' do
          it_behaves_like :test_cdr_partition_check_fail, CdrCurrent do
            let(:timestamps) do
              [ time_now.beginning_of_month - 1.second, time_now.end_of_month + 1.second ]
            end
          end
          it_behaves_like :test_cdr_partition_check_pass, CdrCurrent do
            let(:timestamps) do
              [ time_now.beginning_of_month, time_now.end_of_month ]
            end
          end
        end

        context 'Next month' do
          it_behaves_like :test_cdr_partition_check_fail, CdrNext do
            let(:timestamps) do
              [ next_month.beginning_of_month - 1.second, next_month.end_of_month + 1.second ]
            end
          end
          it_behaves_like :test_cdr_partition_check_pass, CdrNext do
            let(:timestamps) do
              [ next_month.beginning_of_month, next_month.end_of_month ]
            end
          end
        end
      end
    end

  end

end
