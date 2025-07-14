# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlist_items
#
#  id                   :integer(4)       not null, primary key
#  defer_dst_rewrite    :boolean          default(FALSE), not null
#  defer_src_rewrite    :boolean          default(FALSE), not null
#  dst_rewrite_result   :string
#  dst_rewrite_rule     :string
#  key                  :string           not null
#  number_max_length    :integer(2)       default(100), not null
#  number_min_length    :integer(2)       default(0), not null
#  src_rewrite_result   :string
#  src_rewrite_rule     :string
#  tag_action_value     :integer(2)       default([]), not null, is an Array
#  created_at           :timestamptz
#  updated_at           :timestamptz
#  action_id            :integer(2)
#  lua_script_id        :integer(2)
#  numberlist_id        :integer(4)       not null
#  rewrite_ss_status_id :integer(2)
#  tag_action_id        :integer(2)
#
# Indexes
#
#  blacklist_items_blacklist_id_key_idx  (numberlist_id,key) UNIQUE
#  numberlist_items_prefix_range_idx     (((key)::prefix_range)) USING gist
#
# Foreign Keys
#
#  blacklist_items_blacklist_id_fkey    (numberlist_id => numberlists.id)
#  numberlist_items_lua_script_id_fkey  (lua_script_id => lua_scripts.id)
#  numberlist_items_tag_action_id_fkey  (tag_action_id => tag_actions.id)
#
FactoryBot.define do
  factory :numberlist_item, class: 'Routing::NumberlistItem' do
    sequence(:key) { |n| "numberlist_item_#{n}" }

    association :numberlist
    association :lua_script

    action_id { Routing::NumberlistItem::ACTION_REJECT }

    trait :filled do
      tag_action { Routing::TagAction.take }
    end
  end
end
