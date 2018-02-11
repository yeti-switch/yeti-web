module RoutingTagIdsDecorator

  # TODO: this is very very bad for index page
  # replace with has_many :routing_tags
  def routing_tags
    if model.routing_tag_ids.empty?
      return h.content_tag(:span, 'NOT TAGGED', class: 'status_tag')
    end
    model.routing_tag_ids.map do |id|
      tag_name = id ? Routing::RoutingTag.find(id).name : 'any tags'
      h.content_tag(:span, tag_name, class: 'status_tag ok')
    end.join('&nbsp;').html_safe
  end

  def routing_tag_options
    arr = Routing::RoutingTag.all.pluck(:name, :id)
    arr.push(['any tags', nil])
  end

end
