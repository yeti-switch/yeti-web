require 'spec_helper'

RSpec.describe Cdr::AuthLogTable, type: :model do

  include_examples :test_table_partitioning do
    let(:factory_name) { :auth_log }

    let(:expected_constants) do
      {
        table_name: 'sys.auth_log_tables',
        partition_schema: 'auth_log',
        partitioned_table: 'auth_log.auth_log',
        partitioned_table_without_schema: 'auth_log',
        partition_prefix: 'auth_log',
        partition_key: :request_time
      }
    end
  end

  it 'divides partitions by days' do
    expect(described_class.partition_range).to eq(:day)
  end

end
