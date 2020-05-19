# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlist_items
#
#  id                 :integer          not null, primary key
#  numberlist_id      :integer          not null
#  key                :string           not null
#  created_at         :datetime
#  updated_at         :datetime
#  action_id          :integer
#  src_rewrite_rule   :string
#  src_rewrite_result :string
#  dst_rewrite_rule   :string
#  dst_rewrite_result :string
#  tag_action_id      :integer
#  tag_action_value   :integer          default([]), not null, is an Array
#  number_min_length  :integer          default(0), not null
#  number_max_length  :integer          default(100), not null
#  lua_script_id      :integer
#

class Routing::NumberlistItem < Yeti::ActiveRecord
  has_paper_trail class_name: 'AuditLogItem'

  self.table_name = 'class4.numberlist_items'

  belongs_to :numberlist, class_name: 'Routing::Numberlist', foreign_key: :numberlist_id
  belongs_to :action, class_name: 'Routing::NumberlistAction', foreign_key: :action_id
  belongs_to :tag_action, class_name: 'Routing::TagAction'
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id
  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  validates :key, uniqueness: { scope: [:numberlist_id] }

  validates :number_min_length, :number_max_length, presence: true
  validates :number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }

  validates :numberlist, presence: true

  validates_with TagActionValueValidator

  def display_name
    "#{key} | #{id}"
  end
end
