# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlists
#
#  id                         :integer          not null, primary key
#  name                       :string           not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  mode_id                    :integer          default(1), not null
#  default_action_id          :integer          default(1), not null
#  default_src_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_dst_rewrite_result :string
#  tag_action_id              :integer
#  tag_action_value           :integer          default([]), not null, is an Array
#  lua_script_id              :integer
#

class Routing::Numberlist < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'
  self.table_name = 'class4.numberlists'

  belongs_to :mode, class_name: 'Routing::NumberlistMode', foreign_key: :mode_id
  belongs_to :default_action, class_name: 'Routing::NumberlistAction', foreign_key: :default_action_id
  belongs_to :tag_action, class_name: 'Routing::TagAction'
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id

  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  has_many :routing_numberlist_items, class_name: 'Routing::NumberlistItem', foreign_key: :numberlist_id, dependent: :delete_all

  validates_presence_of :mode, :name, :default_action
  validates_uniqueness_of :name

  validates_with TagActionValueValidator

  def display_name
    "#{name} | #{id}"
  end
end
