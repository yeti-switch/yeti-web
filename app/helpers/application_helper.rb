# frozen_string_literal: true

module ApplicationHelper
  def form_title(title = nil)
    verb = case params[:action]
           when 'create'
             'new'
           when 'update'
             'edit'
           else
             params[:action]
           end
    I18n.t("active_admin.#{verb}_model", model: (title || active_admin_config.resource_label))
  end

  def whodunit_link(who)
    who = whodunit(who)

    if who.is_a?(AdminUser)
      link_to who.username, admin_user_path(who)
    else
      who || 'Unknown!'
    end
  end

  def whodunit(who)
    id = who.to_i
    if id > 0
      begin
        AdminUser.find(id)
      rescue StandardError
        who
      end
    else
      who
    end
  end

  def pre_wrap(value, options = {})
    options[:style] = [options[:style], 'white-space: pre-wrap; word-wrap: break-word;'].compact.join(' ')
    content_tag :pre, value, options
  end

  def pre_wrap_json(json, options = {})
    html_options = options.delete(:html) || {}
    pre_wrap JSON.pretty_generate(json, options), html_options
  end

  def versioning_enabled_for_model?(model)
    YetiConfig.versioning_disable_for_models.exclude?(model.name)
  end

  def short_text(text, max_length:)
    return text if text.nil? || text.size <= max_length

    "#{text[0..max_length]}..."
  end

  def routing_tags_map
    @routing_tags_map ||= Routing::RoutingTag.all.pluck(:id, :name).to_h
  end

  def tag_action_value_options
    @tag_action_value_options ||= Routing::RoutingTag.all.map { |record| [record.display_name, record.id] }
  end

  def routing_tag_options
    @routing_tag_options ||= routing_tags_map.invert.to_a + [[Routing::RoutingTag::ANY_TAG, nil]]
  end

  def routing_tags_badges(routing_tag_ids:, routing_tag_mode_id:)
    separator_character = routing_tag_mode_id == Routing::RoutingTagMode::CONST::AND ? ' & ' : ' <b>|</b> '
    if routing_tag_ids.blank?
      return tag.span(Routing::RoutingTag::NOT_TAGGED, class: 'status_tag')
    end

    routing_tag_ids.map do |tag_id|
      if tag_id.nil?
        tag.span(Routing::RoutingTag::ANY_TAG, class: 'status_tag ok')
      else
        tag_name = routing_tags_map[tag_id]
        tag_name.present? ? tag.span(tag_name, class: 'status_tag ok') : tag.span(tag_id, class: 'status_tag warning')
      end
    end.join(separator_character).html_safe
  end

  def tag_action_values_badges(tag_action_value)
    tag_action_value.map do |id|
      tag_name = routing_tags_map[id]
      tag.span(tag_name, class: 'status_tag ok')
    end.join('&nbsp;').html_safe
  end

  def with_tooltip(tooltip_text)
    tooltip_options = { class: 'has_tooltip', title: tooltip_text }
    content_tag(:div, tooltip_options) { yield }
  end
end
