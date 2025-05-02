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

  def decorated_legb_ruri
    return nil if model.legb_ruri.nil?

    h.authorized?(:allow_full_dst_number) ? model.legb_ruri : model.legb_ruri.gsub(/([0-9]{3})(?=@)/, '***')
  end

  def decorated_phone_field(field_name)
    value = model.public_send(field_name)
    return nil if value.blank?

    h.authorized?(:allow_full_dst_number) ? value : mask_phone_number(value)
  end

  def decorated_dst_prefix_in
    decorated_phone_field(:dst_prefix_in)
  end

  def decorated_dst_prefix_routing
    decorated_phone_field(:dst_prefix_routing)
  end

  def decorated_dst_prefix_out
    decorated_phone_field(:dst_prefix_out)
  end

  private

  def mask_phone_number(phone_number)
    if phone_number.length > 3
      phone_number[0..-4] + '***'
    else
      phone_number
    end
  end
end
