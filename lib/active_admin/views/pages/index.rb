class ActiveAdmin::Views::Pages::Index


  def render_blank_slate
    blank_slate_content = config.options[:blank_slate_content]
    if blank_slate_content.is_a?(Proc)
      blank_slate_content = blank_slate_content.call
    end
    blank_slate_content ||= I18n.t("active_admin.blank_slate.content", resource_name: active_admin_config.plural_resource_label)
    if controller.action_methods.include?('new') && authorized?(ActiveAdmin::Auth::CREATE, active_admin_config.resource_class)
      blank_slate_content = [blank_slate_content, blank_slate_link].compact.join(" ")
    end
    if config.options[:partial]
      render partial: config.options[:partial]
    end

    insert_tag(view_factory.blank_slate, blank_slate_content)
  end


  def title
    case config[:title]
      when Symbol, Proc
        call_method_or_proc_on(resource, config[:title])
      when String
        config[:title]
      else
        active_admin_config.plural_resource_label
    end
  end

end

