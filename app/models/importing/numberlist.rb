# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_numberlists
#
#  id                         :integer          not null, primary key
#  o_id                       :integer
#  error_string               :string
#  name                       :string
#  mode_id                    :integer
#  mode_name                  :string
#  default_action_id          :integer
#  default_action_name        :string
#  default_src_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_dst_rewrite_result :string
#  tag_action_id              :integer
#  tag_action_name            :string
#  tag_action_value           :integer          default([]), not null, is an Array
#  tag_action_value_names     :string
#  lua_script_id              :integer
#  lua_script_name            :string
#

class Importing::Numberlist < Importing::Base
  self.table_name = 'data_import.import_numberlists'
  attr_accessor :file

  belongs_to :mode, class_name: 'Routing::NumberlistMode'
  belongs_to :default_action, class_name: 'Routing::NumberlistAction'
  belongs_to :tag_action, class_name: 'Routing::TagAction'
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id

  self.import_class = ::Routing::Numberlist

  self.import_attributes = %w[name mode_id default_action_id
                              default_src_rewrite_rule default_src_rewrite_result
                              default_dst_rewrite_rule default_dst_rewrite_result
                              tag_action_id tag_action_value lua_script_id]

  def self.after_import_hook(unique_columns = [])
    resolve_array_of_tags('tag_action_value', 'tag_action_value_names')
    super
  end
end
