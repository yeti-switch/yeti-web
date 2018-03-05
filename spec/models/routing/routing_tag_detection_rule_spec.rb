# == Schema Information
#
# Table name: class4.routing_tag_detection_rules
#
#  id               :integer          not null, primary key
#  dst_area_id      :integer
#  src_area_id      :integer
#  tag_action_id    :integer
#  tag_action_value :integer          default([]), not null, is an Array
#

require 'spec_helper'

RSpec.describe Routing::RoutingTagDetectionRule, type: :model do

  context '#validations' do

    include_examples :test_model_with_tag_action

  end

end
