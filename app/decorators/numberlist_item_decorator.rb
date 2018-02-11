class NumberlistItemDecorator < Draper::Decorator

  delegate_all
  decorates Routing::NumberlistItem

  # TODO: must be another way to share decorated methods
  include RoutingTagActionDecorator

end
