# frozen_string_literal: true

class RsReplication < ApplicationRecord
  self.table_name = 'pg_stat_replication'
  attribute :write_lag, :string
  attribute :flush_lag, :string
  attribute :replay_lag, :string
end
