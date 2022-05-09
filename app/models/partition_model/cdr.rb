# frozen_string_literal: true

module PartitionModel
  class Cdr < ::PartitionModel::Base
    self.pg_partition_name = 'PgPartition::Cdr'
    self.pg_partition_model_names = ['Cdr::Cdr', 'Cdr::AuthLog', 'RtpStatistics::TxStream', 'RtpStatistics::RxStream'].freeze
  end
end
