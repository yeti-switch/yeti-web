# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlists
#
#  id                         :integer          not null, primary key
#  name                       :string           not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  mode_id                    :integer          default(1), not null
#  default_action_id          :integer          default(1), not null
#  default_src_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_dst_rewrite_result :string
#  tag_action_id              :integer
#  tag_action_value           :integer          default([]), not null, is an Array
#  lua_script_id              :integer
#  external_id                :integer
#

RSpec.describe Routing::Numberlist, type: :model do
  context '#validations' do
    include_examples :test_model_with_tag_action
  end
end
