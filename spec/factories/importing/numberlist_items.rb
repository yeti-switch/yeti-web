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
#  src_rewrite_result     :string
#  src_rewrite_rule       :string
#  tag_action_name        :string
#  tag_action_value       :integer(2)       default([]), not null, is an Array
#  tag_action_value_names :string
#  action_id              :integer(4)
#  lua_script_id          :integer(2)
#  numberlist_id          :integer(2)
#  o_id                   :integer(4)
#  tag_action_id          :integer(4)
#
FactoryBot.define do
  factory :importing_numberlist_item, class: 'Importing::NumberlistItem' do
    transient do
      _numberlist { Routing::Numberlist.take || create(:numberlist) }
      _action_id { Routing::NumberlistItem::ACTION_REJECT }
      _action_name { Routing::NumberlistItem::ACTIONS[Routing::NumberlistItem::ACTION_REJECT] }
      _tag_action { Routing::TagAction.take }
      _routing_tags { create_list(:routing_tag, 2) }
    end

    o_id { nil }
    error_string { nil }

    sequence(:key) { |n| "RSpec Import Numberlist Item n-#{n}" }

    numberlist_id { _numberlist.id }
    numberlist_name { _numberlist.name }

    action_id { _action_id }
    action_name { _action_name }

    number_min_length { 5 }
    number_max_length { 10 }
    src_rewrite_rule { '111' }
    src_rewrite_result { '222' }
    dst_rewrite_rule { '333' }
    dst_rewrite_result { '444' }

    tag_action_id { _tag_action.id }
    tag_action_name { _tag_action.name }

    tag_action_value { _routing_tags.map(&:id) }
    tag_action_value_names { _routing_tags.map(&:name).join(', ') }
  end
end
