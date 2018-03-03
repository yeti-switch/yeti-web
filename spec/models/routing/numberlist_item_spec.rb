# == Schema Information
#
# Table name: class4.numberlist_items
#
#  id                 :integer          not null, primary key
#  numberlist_id      :integer          not null
#  key                :string           not null
#  created_at         :datetime
#  updated_at         :datetime
#  action_id          :integer
#  src_rewrite_rule   :string
#  src_rewrite_result :string
#  dst_rewrite_rule   :string
#  dst_rewrite_result :string
#  tag_action_id      :integer
#  tag_action_value   :integer          default([]), not null, is an Array
#

require 'spec_helper'

RSpec.describe Routing::NumberlistItem, type: :model do

  context '#validations' do

    include_examples :test_model_with_tag_action

  end

end
