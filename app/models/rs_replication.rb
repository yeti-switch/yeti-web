class RsReplication < ActiveRecord::Base
  self.table_name = 'pg_stat_replication'

end