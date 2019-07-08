# frozen_string_literal: true

module PartitionModel
  class Log < ::PartitionModel::Base
    self.pg_partition_name = 'PgPartition::Yeti'
    self.pg_partition_model_names = ['Log::ApiLog'].freeze
  end
end
