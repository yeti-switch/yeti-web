# == Schema Information
#
# Table name: sys.lua_scripts
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  source     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class System::LuaScript < ActiveRecord::Base
  self.table_name = 'sys.lua_scripts'

  has_paper_trail class_name: 'AuditLogItem'

  validates :name, uniqueness: true, presence: true

  validates_presence_of :source
end
