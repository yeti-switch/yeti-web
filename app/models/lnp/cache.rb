# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_cache
#
#  id          :integer(4)       not null, primary key
#  data        :string
#  dst         :string           not null
#  expires_at  :datetime
#  lrn         :string           not null
#  tag         :string
#  created_at  :datetime
#  updated_at  :datetime
#  database_id :integer(2)
#
# Indexes
#
#  lnp_cache_dst_database_id_idx  (dst,database_id) UNIQUE
#  lnp_cache_expires_at_idx       (expires_at)
#
# Foreign Keys
#
#  lnp_cache_database_id_fkey  (database_id => lnp_databases.id)
#

class Lnp::Cache < Yeti::ActiveRecord
  self.table_name = 'class4.lnp_cache'

  belongs_to :database, class_name: 'Lnp::Database', foreign_key: :database_id, optional: true
end
