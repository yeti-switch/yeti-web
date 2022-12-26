# frozen_string_literal: true

FactoryBot.define do
  factory :importing_numberlist_item, class: Importing::NumberlistItem do
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
