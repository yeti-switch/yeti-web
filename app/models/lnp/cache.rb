# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_cache
#
#  id          :integer          not null, primary key
#  dst         :string           not null
#  lrn         :string           not null
#  created_at  :datetime
#  updated_at  :datetime
#  expires_at  :datetime
#  database_id :integer
#  data        :string
#  tag         :string
#

class Lnp::Cache < Yeti::ActiveRecord
  self.table_name = 'class4.lnp_cache'

  belongs_to :database, class_name: 'Lnp::Database', foreign_key: :database_id
end
