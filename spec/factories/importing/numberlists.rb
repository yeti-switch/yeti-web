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
FactoryBot.define do
  factory :importing_numberlist, class: 'Importing::Numberlist' do
    transient do
      _mode_id { Routing::Numberlist::MODE_STRICT }
      _mode_name { Routing::Numberlist::MODES[Routing::Numberlist::MODE_STRICT] }
      _default_action_id { Routing::Numberlist::DEFAULT_ACTION_ACCEPT }
      _default_action_name { Routing::Numberlist::DEFAULT_ACTIONS[Routing::Numberlist::DEFAULT_ACTION_ACCEPT] }
      _tag_action { Routing::TagAction.take }
      _routing_tags { create_list(:routing_tag, 2) }
    end

    o_id { nil }
    error_string { nil }

    sequence(:name) { |n| "RSpec Import Numberlist n-#{n}" }

    mode_id { _mode_id }
    mode_name { _mode_name }

    default_action_id { _default_action_id }
    default_action_name { _default_action_name }

    default_src_rewrite_rule { '111' }
    default_src_rewrite_result { '222' }
    default_dst_rewrite_rule { '333' }
    default_dst_rewrite_result { '444' }

    tag_action_id { _tag_action.id }
    tag_action_name { _tag_action.name }

    tag_action_value { _routing_tags.map(&:id) }
    tag_action_value_names { _routing_tags.map(&:name).join(', ') }
  end
end
