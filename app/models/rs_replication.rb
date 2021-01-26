# frozen_string_literal: true

class RsReplication < ApplicationRecord
  self.table_name = 'pg_stat_replication'
end
