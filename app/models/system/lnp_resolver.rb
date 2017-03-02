# == Schema Information
#
# Table name: sys.lnp_resolvers
#
#  id      :integer          not null, primary key
#  name    :string           not null
#  address :string           not null
#  port    :integer          not null
#

class System::LnpResolver < Yeti::ActiveRecord
  self.table_name = 'sys.lnp_resolvers'
  validates_uniqueness_of :name
  validates_presence_of :name, :address, :port
  
  has_paper_trail class_name: 'AuditLogItem'

  def display_name
    "#{self.name}"
  end

end
