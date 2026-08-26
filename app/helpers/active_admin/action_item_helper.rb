# frozen_string_literal: true

module ActiveAdmin::ActionItemHelper
  # Renders a page-header action item.
  #
  # ActiveAdmin 4 styles action items through the `action-item-button` class —
  # its own "New <resource>" item carries it, and anything else has to opt in.
  # (ActiveAdmin 3 styled the container instead, `.action_items a`, so the
  # `action_item` blocks in app/admin and lib/resource_dsl never needed a class.)
  #
  # The signature mirrors `link_to`, so call sites differ from it only in name.
  # That matters for the several call sites that pass url options positionally
  # (`action_item_link 'History', action: :history, id: resource.id`): the hash
  # lands in `options`, exactly as `link_to` would take it, and the class is
  # merged into `html_options` rather than into the URL.
  def action_item_link(name = nil, options = nil, html_options = nil, &block)
    html_options = (html_options || {}).dup
    html_options[:class] = [html_options[:class], 'action-item-button'].compact.join(' ')

    if block
      link_to(options, html_options, &block)
    else
      link_to(name, options, html_options)
    end
  end
end
