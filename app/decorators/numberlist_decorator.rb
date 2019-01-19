# frozen_string_literal: true

class NumberlistDecorator < Draper::Decorator
  delegate_all
  decorates Routing::Numberlist

  # TODO: must be another way to share decorated methods
  include RoutingTagActionDecorator
end
