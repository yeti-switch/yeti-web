FactoryGirl.define do
  factory :routing_tag_detection_rule, class: Routing::RoutingTagDetectionRule do

    tag_action { Routing::TagAction.clear_action }
  end
end
