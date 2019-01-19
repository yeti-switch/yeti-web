# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cdr::Table, type: :model do
  include_examples :test_table_partitioning do
    let(:factory_name) { :cdr }

    let(:expected_constants) do
      {
        table_name: 'sys.cdr_tables',
        partition_schema: 'cdr',
        partitioned_table: 'cdr.cdr',
        partitioned_table_without_schema: 'cdr',
        partition_prefix: 'cdr',
        partition_key: :time_start
      }
    end
  end

  it 'divides partitions by days' do
    expect(described_class.partition_range).to eq(:month)
  end
end
