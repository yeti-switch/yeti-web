# frozen_string_literal: true

class RoutingTagDetectionRuleDecorator < Draper::Decorator
  delegate_all
  decorates Routing::RoutingTagDetectionRule

  # TODO: must be another way to share decorated methods
  include RoutingTagActionDecorator
  include RoutingTagIdsDecorator
end
