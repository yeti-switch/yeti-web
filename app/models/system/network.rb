# == Schema Information
#
# Table name: sys.networks
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class System::Network < Yeti::ActiveRecord
  self.table_name = 'sys.networks'
  validates_uniqueness_of :name
  validates_presence_of :name
  has_many :prefixes, class_name: 'System::NetworkPrefix'

  has_paper_trail class_name: 'AuditLogItem'


  def display_name
    "#{id} | #{name}"
  end

  def self.collection
    order(:name)
  end

end
