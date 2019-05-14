# frozen_string_literal: true
# == Schema Information
#
# Table name: data_import.import_numberlist_items
#
#  id                     :integer          not null, primary key
#  o_id                   :integer
#  error_string           :string
#  numberlist_id          :integer
#  numberlist_name        :string
#  key                    :string
#  action_id              :integer
#  action_name            :string
#  src_rewrite_rule       :string
#  src_rewrite_result     :string
#  dst_rewrite_rule       :string
#  dst_rewrite_result     :string
#  tag_action_id          :integer
#  tag_action_name        :string
#  tag_action_value       :integer          default([]), not null, is an Array
#  tag_action_value_names :string
#  number_min_length      :integer
#  number_max_length      :integer
#  lua_script_id          :integer
#  lua_script_name        :string
#

class Importing::NumberlistItem < Importing::Base
  self.table_name = 'data_import.import_numberlist_items'
  attr_accessor :file

  belongs_to :numberlist, class_name: 'Routing::Numberlist'
  belongs_to :action, class_name: 'Routing::NumberlistAction'
  belongs_to :tag_action, class_name: 'Routing::TagAction'
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id

  self.import_class = ::Routing::NumberlistItem

  self.import_attributes = %w[numberlist_id
                              key number_min_length number_max_length
                              action_id
                              src_rewrite_rule src_rewrite_result
                              dst_rewrite_rule dst_rewrite_result
                              tag_action_id tag_action_value lua_script_id]

  def self.after_import_hook(unique_columns = [])
    resolve_array_of_tags('tag_action_value', 'tag_action_value_names')
    super
  end
end
