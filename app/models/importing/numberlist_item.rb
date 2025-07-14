# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_numberlist_items
#
#  id                     :integer(4)       not null, primary key
#  action_name            :string
#  dst_rewrite_result     :string
#  dst_rewrite_rule       :string
#  error_string           :string
#  is_changed             :boolean
#  key                    :string
#  lua_script_name        :string
#  number_max_length      :integer(2)
#  number_min_length      :integer(2)
#  numberlist_name        :string
#  rewrite_ss_status_name :string
#  src_rewrite_result     :string
#  src_rewrite_rule       :string
#  tag_action_name        :string
#  tag_action_value       :integer(2)       default([]), not null, is an Array
#  tag_action_value_names :string
#  action_id              :integer(4)
#  lua_script_id          :integer(2)
#  numberlist_id          :integer(2)
#  o_id                   :integer(4)
#  rewrite_ss_status_id   :integer(2)
#  tag_action_id          :integer(4)
#

class Importing::NumberlistItem < Importing::Base
  self.table_name = 'data_import.import_numberlist_items'
  attr_accessor :file

  belongs_to :numberlist, class_name: 'Routing::Numberlist', optional: true
  belongs_to :tag_action, class_name: 'Routing::TagAction', optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true

  import_for ::Routing::NumberlistItem

  self.import_attributes = %w[numberlist_id
                              key number_min_length number_max_length
                              action_id
                              src_rewrite_rule src_rewrite_result
                              dst_rewrite_rule dst_rewrite_result
                              tag_action_id tag_action_value rewrite_ss_status_id lua_script_id]

  def action_display_name
    action_id.nil? ? 'unknown' : Routing::Numberlist::ACTIONS[action_id]
  end

  def rewrite_ss_status_name
    rewrite_ss_status_id.nil? ? nil : Equipment::StirShaken::Attestation::ATTESTATIONS[rewrite_ss_status_id]
  end

  def self.after_import_hook
    resolve_array_of_tags('tag_action_value', 'tag_action_value_names')
    resolve_integer_constant('action_id', 'action_name', Routing::NumberlistItem::ACTIONS)
    resolve_integer_constant(
      'rewrite_ss_status_id',
      'rewrite_ss_status_name',
      Equipment::StirShaken::Attestation::ATTESTATIONS
    )
    super
  end
end
