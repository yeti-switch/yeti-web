# frozen_string_literal: true

class CdrDecorator < Draper::Decorator
  delegate_all
  decorates Cdr::Cdr

  def decorated_routing_delay
    round5_format :routing_delay
  end

  def decorated_rtt
    round5_format :rtt
  end

  def decorated_pdd
    round5_format :pdd
  end

  def routing_tags
    return nil if model.routing_tag_ids.blank?

    model.routing_tag_ids.map do |id|
      tag_name = h.routing_tags_map[id]
      if tag_name
        h.content_tag(:span, tag_name, class: 'status_tag ok')
      else
        h.content_tag(:span, id, class: 'status_tag no')
      end
    end.join('&nbsp;').html_safe
  end

  def round5_format(attr)
    return nil if model.public_send(attr).nil?

    model.public_send(attr).round(5)
  end
end
