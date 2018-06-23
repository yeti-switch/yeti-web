RSpec.describe 'Edit RoutingTagDetectionRule', type: :feature do
  include_context :login_as_admin

  context 'unset "Tag action value"' do
    include_examples :test_unset_tag_action_value,
                      controller_name: :routing_routing_tag_detection_rules,
                      factory: :routing_tag_detection_rule
  end

  context 'unset "Routin Tag IDs"' do
    include_examples :test_unset_routing_tag_ids,
                      controller_name: :routing_routing_tag_detection_rules,
                      factory: :routing_tag_detection_rule

  end
end
