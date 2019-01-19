# frozen_string_literal: true

module RoutingTagIdsDecorator
  # TODO: this is very very bad for index page
  # replace with has_many :routing_tags
  def routing_tags
    separator_character = routing_tag_mode.and? ? ' & ' : ' <b>|</b> '
    unless model.routing_tag_ids.present?
      return h.content_tag(:span, 'NOT TAGGED', class: 'status_tag')
    end

    model.routing_tags.map do |tag|
      h.content_tag(:span, tag.name, class: 'status_tag ok')
    end.join(separator_character).html_safe
  end

  def routing_tag_options
    arr = Routing::RoutingTag.all.pluck(:name, :id)
    arr.push([Routing::RoutingTag::ANY_TAG, nil])
  end
end
