# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_cache
#
#  id          :integer(4)       not null, primary key
#  data        :string
#  dst         :string           not null
#  expires_at  :timestamptz      not null
#  lrn         :string           not null
#  tag         :string
#  created_at  :timestamptz
#  updated_at  :timestamptz
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

FactoryBot.define do
  factory :lnp_cache, class: Lnp::Cache do
    sequence(:dst) { |n| "dst#{n}" }
    lrn { 'lrn' }
    expires_at { Time.now.utc + 200_000 }
  end
end
