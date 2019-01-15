# frozen_string_literal: true

RSpec.shared_examples :test_table_partitioning do
  before(:each, :before_erase_partitions) do
    connection = described_class.connection
    table_name = described_class.table_name
    partitions = described_class.partitions
    trigger_function_name = described_class.trigger_function_name
    trigger_name = described_class.trigger_name

    described_class.transaction do
      connection.execute("TRUNCATE #{table_name}")
      connection.execute("DROP TABLE #{partitions.join(', ')}") if partitions.present?
      connection.execute %{
        CREATE OR REPLACE FUNCTION #{trigger_function_name}() RETURNS trigger AS $BODY$
        BEGIN
          RAISE EXCEPTION '#{trigger_name}: time_start out of range.';
        RETURN NULL;
        END; $BODY$ LANGUAGE plpgsql;
      }
    end
  end

  let(:schema) { described_class.partition_schema }
  let(:prefix) { described_class.partition_prefix }

  let(:ranges) { described_class.time_slices }

  let(:prev_date) { ranges[0].first.to_time(:utc).beginning_of_day }
  let(:current_date) { ranges[1].first.to_time(:utc).beginning_of_day }
  let(:next_date) { ranges[2].first.to_time(:utc).beginning_of_day }

  let(:out_of_bottom_bound) { ranges.first[0].to_time(:utc).beginning_of_day - 1.second }
  let(:out_of_upper_bound) { ranges.last[1].to_time(:utc).beginning_of_day }

  let(:strftime_format) do
    described_class.partition_range == :day ? '%Y%m%d' : '%Y%m'
  end

  let(:table_name_prev) do
    "#{schema}.#{prefix}_#{prev_date.strftime(strftime_format)}"
  end

  let(:table_name_current) do
    "#{schema}.#{prefix}_#{current_date.strftime(strftime_format)}"
  end

  let(:table_name_next) do
    "#{schema}.#{prefix}_#{next_date.strftime(strftime_format)}"
  end

  context 'class variables' do
    it 'has valid class variables' do
      expect(described_class).to have_attributes(
        table_name: expected_constants[:table_name],
        partition_schema: expected_constants[:partition_schema],
        partitioned_table: expected_constants[:partitioned_table],
        partitioned_table_without_schema: expected_constants[:partitioned_table_without_schema],
        partition_prefix: expected_constants[:partition_prefix],
        partition_key: expected_constants[:partition_key]
      )
    end
  end

  subject { described_class.add_partition }

  context 'when partitions already exists' do
    it 'do not raise errors when call add_partition twice' do
      expect do
        described_class.add_partition
        described_class.add_partition
      end.not_to raise_error
    end
  end

  context 'when partition not exists', :before_erase_partitions do
    it 'creates three partitions (previous + current + next months)' do
      expect { subject }.to change {
        [described_class.partitions.count, described_class.count]
      }.from([0, 0]).to([3, 3])
    end

    it 'inserts records into specific partition' do
      def create_record(timestamp)
        create(factory_name, described_class.partition_key => timestamp)
      end

      def rows_count(date:)
        described_class.connection.execute(
          "SELECT id FROM #{described_class.partition_schema}.#{described_class.partition_prefix}_#{date.strftime(strftime_format)}"
        ).to_a.size
      end

      subject

      # out of range
      expect { create_record(out_of_bottom_bound) }
        .to raise_error(ActiveRecord::StatementInvalid)
      expect { create_record(out_of_upper_bound) }
        .to raise_error(ActiveRecord::StatementInvalid)

      # current month
      expect { create_record(current_date) }
        .to change { rows_count(date: current_date) }.by(1)
      expect { create_record(next_date - 1.second) }
        .to change { rows_count(date: current_date) }.by(1)

      # prev month
      expect { create_record(prev_date) }
        .to change { rows_count(date: prev_date) }.by(1)
      expect { create_record(current_date - 1.second) }
        .to change { rows_count(date: prev_date) }.by(1)

      # next months
      expect { create_record(next_date) }
        .to change { rows_count(date: next_date) }.by(1)
      expect { create_record(out_of_upper_bound - 1.second) }
        .to change { rows_count(date: next_date) }.by(1)
    end

    it 'container-table has information about partitions' do
      expect(described_class.count).to eq(0)

      subject

      expect(described_class.all).to all(
        have_attributes(readable: true, writable: true, active: true)
      )
      expect(described_class.all).to match([
                                             have_attributes(name: table_name_prev, date_start: ranges[0][0].to_s(:db), date_stop: ranges[0][1].to_s(:db)),
                                             have_attributes(name: table_name_current, date_start: ranges[1][0].to_s(:db), date_stop: ranges[1][1].to_s(:db)),
                                             have_attributes(name: table_name_next, date_start: ranges[2][0].to_s(:db), date_stop: ranges[2][1].to_s(:db))
                                           ])
    end

    describe 'Each month-table has time-period CONSTRAINT' do
      shared_examples :test_cdr_partition_check_fail do
        it 'should fail' do
          timestamps.each do |time_start|
            expect do
              klass.create!(
                build(factory_name, described_class.partition_key => time_start).attributes
              )
            end.to raise_error(ActiveRecord::StatementInvalid)
          end
        end
      end

      shared_examples :test_cdr_partition_check_pass do
        it 'should save' do
          timestamps.each do |time_start|
            expect do
              klass.create!(
                build(factory_name, described_class.partition_key => time_start).attributes
              )
            end.to change { klass.count }.by(1)
          end
        end
      end

      before do
        subject

        # need to redefine here as local variables
        _tb_prev = table_name_prev
        _tb_curr = table_name_current
        _tb_next = table_name_next

        @tablePrev = Class.new(described_class.partitioned_model) do
          self.table_name = _tb_prev
        end
        @tableCurrent = Class.new(described_class.partitioned_model) do
          self.table_name = _tb_curr
        end
        @tableNext = Class.new(described_class.partitioned_model) do
          self.table_name = _tb_next
        end
      end

      after do
        @tablePrev.delete_all
        @tableCurrent.delete_all
        @tableNext.delete_all
      end

      context 'Previous range' do
        let(:klass) { @tablePrev }

        it_behaves_like :test_cdr_partition_check_fail do
          let(:timestamps) do
            [prev_date - 1.second, current_date + 1.second]
          end
        end

        it_behaves_like :test_cdr_partition_check_pass do
          let(:timestamps) do
            [prev_date, current_date - 1.second]
          end
        end
      end

      context 'Current range' do
        let(:klass) { @tableCurrent }

        it_behaves_like :test_cdr_partition_check_fail do
          let(:timestamps) do
            [current_date - 1.second, next_date + 1.second]
          end
        end

        it_behaves_like :test_cdr_partition_check_pass do
          let(:timestamps) do
            [current_date, next_date - 1.second]
          end
        end
      end

      context 'Next range' do
        let(:klass) { @tableNext }

        it_behaves_like :test_cdr_partition_check_fail do
          let(:timestamps) do
            [next_date - 1.second, out_of_upper_bound]
          end
        end

        it_behaves_like :test_cdr_partition_check_pass do
          let(:timestamps) do
            [next_date, out_of_upper_bound - 1.second]
          end
        end
      end
    end
  end
end
