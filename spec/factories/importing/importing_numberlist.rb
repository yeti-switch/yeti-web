# frozen_string_literal: true

FactoryBot.define do
  factory :importing_numberlist, class: Importing::Numberlist do
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
