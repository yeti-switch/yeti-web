# frozen_string_literal: true

module PartitionModel
  class Cdr < ::PartitionModel::Base
    self.pg_partition_name = 'PgPartition::Cdr'
    self.pg_partition_model_names = ['Cdr::Cdr', 'Cdr::AuthLog', 'Cdr::RtpStatistic'].freeze
  end
end
