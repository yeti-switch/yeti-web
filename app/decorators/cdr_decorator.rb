# frozen_string_literal: true

class CdrDecorator < Draper::Decorator
  delegate_all
  decorates Cdr::Cdr

  def routing_tags
    return nil if model.routing_tag_ids.blank?

    model.routing_tag_ids.map do |id|
      tag = Routing::RoutingTag.where(id: id).first
      if tag
        h.content_tag(:span, tag.name, class: 'status_tag ok')
      else
        h.content_tag(:span, id, class: 'status_tag no')
      end
    end.join('&nbsp;').html_safe
  end
end
