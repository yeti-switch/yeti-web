# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlists
#
#  id                         :integer(4)       not null, primary key
#  default_dst_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_src_rewrite_rule   :string
#  defer_dst_rewrite          :boolean          default(FALSE), not null
#  defer_src_rewrite          :boolean          default(FALSE), not null
#  external_type              :string
#  name                       :string           not null
#  tag_action_value           :integer(2)       default([]), not null, is an Array
#  variables                  :jsonb
#  created_at                 :timestamptz
#  updated_at                 :timestamptz
#  default_action_id          :integer(2)       default(1), not null
#  external_id                :bigint(8)
#  lua_script_id              :integer(2)
#  mode_id                    :integer(2)       default(1), not null
#  rewrite_ss_status_id       :integer(2)
#  tag_action_id              :integer(2)
#
# Indexes
#
#  blacklists_name_key                             (name) UNIQUE
#  numberlists_external_id_external_type_key_uniq  (external_id,external_type) UNIQUE
#  numberlists_external_id_key_uniq                (external_id) UNIQUE WHERE (external_type IS NULL)
#
# Foreign Keys
#
#  numberlists_lua_script_id_fkey  (lua_script_id => lua_scripts.id)
#  numberlists_tag_action_id_fkey  (tag_action_id => tag_actions.id)
#
FactoryBot.define do
  factory :numberlist, class: 'Routing::Numberlist' do
    sequence(:name) { |n| "numberlist#{n}" }

    association :lua_script

    mode_id { Routing::Numberlist::MODE_STRICT }
    default_action_id { Routing::Numberlist::DEFAULT_ACTION_REJECT }

    trait :filled do
      tag_action { Routing::TagAction.take }
    end

    trait :with_external_id do
      sequence(:external_id)
    end
  end
end
