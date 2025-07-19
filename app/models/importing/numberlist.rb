# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_numberlists
#
#  id                         :integer(4)       not null, primary key
#  default_action_name        :string
#  default_dst_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_src_rewrite_rule   :string
#  error_string               :string
#  is_changed                 :boolean
#  lua_script_name            :string
#  mode_name                  :string
#  name                       :string
#  rewrite_ss_status_name     :string
#  tag_action_name            :string
#  tag_action_value           :integer(2)       default([]), not null, is an Array
#  tag_action_value_names     :string
#  default_action_id          :integer(4)
#  lua_script_id              :integer(2)
#  mode_id                    :integer(4)
#  o_id                       :integer(2)
#  rewrite_ss_status_id       :integer(2)
#  tag_action_id              :integer(4)
#

class Importing::Numberlist < Importing::Base
  self.table_name = 'data_import.import_numberlists'
  attr_accessor :file

  belongs_to :tag_action, class_name: 'Routing::TagAction', optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true

  import_for ::Routing::Numberlist

  self.import_attributes = %w[name mode_id default_action_id
                              default_src_rewrite_rule default_src_rewrite_result
                              default_dst_rewrite_rule default_dst_rewrite_result
                              tag_action_id tag_action_value rewrite_ss_status_id lua_script_id]

  def default_action_display_name
    default_action_id.nil? ? 'unknown' : Routing::Numberlist::DEFAULT_ACTIONS[default_action_id]
  end

  def mode_display_name
    mode_id.nil? ? 'unknown' : Routing::Numberlist::MODES[mode_id]
  end

  def rewrite_ss_status_name
    rewrite_ss_status_id.nil? ? nil : Equipment::StirShaken::Attestation::ATTESTATIONS[rewrite_ss_status_id]
  end

  def self.after_import_hook
    resolve_array_of_tags('tag_action_value', 'tag_action_value_names')
    resolve_integer_constant('mode_id', 'mode_name', Routing::Numberlist::MODES)
    resolve_integer_constant('default_action_id', 'default_action_name', Routing::Numberlist::DEFAULT_ACTIONS)
    resolve_integer_constant(
      'rewrite_ss_status_id',
      'rewrite_ss_status_name',
      Equipment::StirShaken::Attestation::ATTESTATIONS
    )
    super
  end
end
