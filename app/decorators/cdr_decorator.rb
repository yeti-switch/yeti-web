# frozen_string_literal: true

class CdrDecorator < Draper::Decorator
  delegate_all
  decorates Cdr::Cdr

  def routing_tags
    return nil unless model.routing_tag_ids.present?

    model.routing_tag_ids.map do |id|
      tag = Routing::RoutingTag.where(id: id).first
      if tag
        h.content_tag(:span, tag.name, class: 'status_tag ok')
      else
        h.content_tag(:span, id, class: 'status_tag no')
      end
    end.join('&nbsp;').html_safe
  end

  def id_link
    payload = [h.link_to(model.id, h.resource_path(cdr), class: 'resource_id_link', title: 'Details')]
    if model.dump_level_id > 0
      payload.push h.link_to(fa_icon('exchange'), h.dump_cdr_path(model), title: 'Download trace')
    end
    payload.join(' ')
  end

  %i[lega_disconnect_code internal_disconnect_code legb_disconnect_code].each do |meth|
    define_method("#{meth}_badge") do
      value = model.public_send(meth)
      if !value.nil? && value != 0
        { label: value.to_s, class: (model.success? ? :ok : :red) }
      else
        nil
      end
    end
  end
end
