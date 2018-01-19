require 'spec_helper'

describe 'Edit RoutingTagDetectionRule', type: :feature do
  include_context :login_as_admin

  context 'unset "Tag action value"' do
    include_examples :test_unset_tag_action_value,
                      controller_name: :routing_routing_tag_detection_rules do

      let(:record) do
        create(:routing_tag_detection_rule, routing_tag: tag)
      end
    end

  end

end
