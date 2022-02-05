# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_alcazar
#
#  id      :integer(2)       not null, primary key
#  host    :string           not null
#  key     :string           not null
#  port    :integer(4)
#  timeout :integer(2)       default(300), not null
#

class Lnp::DatabaseAlcazar < ApplicationRecord
  self.table_name = 'class4.lnp_databases_alcazar'

  #
  # Query:  
  # http://api.east.alcazarnetworks.com/api/2.2/lrn?tn=14846642959&key=5ddc2fba-0cc4-4c93-9a28-bd28ddf5e6d4    
  #
  # Output:  
  # 14847880088

  has_one :lnp_database, as: :database, class_name: 'Lnp::Database'

  validates :host, :key, presence: true
  validates :timeout, allow_nil: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: PG_MAX_SMALLINT,
    only_integer: true
  }
end
