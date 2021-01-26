# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.lua_scripts
#
#  id         :integer(2)       not null, primary key
#  name       :string           not null
#  source     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  lua_scripts_name_key  (name) UNIQUE
#

class System::LuaScript < ActiveRecord::Base
  self.table_name = 'sys.lua_scripts'

  has_many :gateways, class_name: 'Gateway', foreign_key: :lua_script_id, dependent: :restrict_with_error
  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: :lua_script_id, dependent: :restrict_with_error
  has_many :numberlists, class_name: 'Routing::Numberlist', foreign_key: :lua_script_id, dependent: :restrict_with_error
  has_many :numberlist_items, class_name: 'Routing::NumberlistItem', foreign_key: :lua_script_id, dependent: :restrict_with_error

  validates :name, uniqueness: true, presence: true
  validates :source, presence: true
end
