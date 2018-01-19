module RoutingTagActionDecorator

  # TODO: this is very very bad for index page
  # replace with has_many :routing_tags
  def routing_tags
    model.tag_action_value.map do |id|
      h.content_tag(:span, Routing::RoutingTag.find(id).name, class: 'status_tag ok')
    end.join('&nbsp;').html_safe
  end

end
