# == Schema Information
#
# Table name: class4.lnp_databases
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  host           :string           not null
#  port           :integer
#  driver_id      :integer          not null
#  created_at     :datetime
#  thinq_token    :string
#  thinq_username :string
#  timeout        :integer          default(300), not null
#  csv_file       :string
#

class Lnp::Database< Yeti::ActiveRecord
  self.table_name = 'class4.lnp_databases'

  belongs_to :driver, class_name: Lnp::DatabaseDriver, foreign_key: :driver_id
  validates_presence_of :driver, :name, :host
  validates_uniqueness_of :name

  validates_numericality_of :timeout, greater_than: 0, less_than: PG_MAX_SMALLINT, allow_nil: true, only_integer: true


  def display_name
    "#{self.name} | #{self.id}"
  end
  
  def test_db(destination)
    transaction do
      self.fetch_sp_val("select * from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.init(0,0)") #loading configuration
      d=self.fetch_sp("select lrn, tag from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.lnp_resolve_tagged(?::smallint,?::varchar)",
                                      self.id,
                                      destination
      )[0]
      OpenStruct.new(d)
    end
  end

end
