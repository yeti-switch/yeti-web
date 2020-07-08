# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlists
#
#  id                         :integer(2)       not null, primary key
#  default_dst_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_src_rewrite_rule   :string
#  name                       :string           not null
#  tag_action_value           :integer(2)       default([]), not null, is an Array
#  created_at                 :datetime
#  updated_at                 :datetime
#  default_action_id          :integer(2)       default(1), not null
#  external_id                :bigint(8)
#  lua_script_id              :integer(2)
#  mode_id                    :integer(2)       default(1), not null
#  tag_action_id              :integer(2)
#
# Indexes
#
#  blacklists_name_key          (name) UNIQUE
#  numberlists_external_id_key  (external_id) UNIQUE
#
# Foreign Keys
#
#  blacklists_mode_id_fkey             (mode_id => numberlist_modes.id)
#  numberlists_default_action_id_fkey  (default_action_id => numberlist_actions.id)
#  numberlists_lua_script_id_fkey      (lua_script_id => lua_scripts.id)
#  numberlists_tag_action_id_fkey      (tag_action_id => tag_actions.id)
#

RSpec.describe Routing::Numberlist, type: :model do
  context '#validations' do
    include_examples :test_model_with_tag_action
  end
end
