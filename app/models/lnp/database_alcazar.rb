# == Schema Information
#
# Table name: class4.lnp_databases_alcazar
#
#  id          :integer          not null, primary key
#  host        :string           not null
#  port        :integer
#  timeout     :integer          default(300), not null
#  key         :string           not null
#  database_id :integer
#

class Lnp::DatabaseAlcazar < Yeti::ActiveRecord
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
