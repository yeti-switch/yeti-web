# frozen_string_literal: true

class ActiveAdmin::Views::Pages::Index
  def render_blank_slate
    blank_slate_content = config.options[:blank_slate_content]
    disable_blank_slate_link = config.options[:disable_blank_slate_link]

    if blank_slate_content.is_a?(Proc)
      blank_slate_content = blank_slate_content.call
    end
    blank_slate_content ||= I18n.t('active_admin.blank_slate.content', resource_name: active_admin_config.plural_resource_label)
    if controller.action_methods.include?('new') && authorized?(ActiveAdmin::Auth::CREATE, active_admin_config.resource_class) && disable_blank_slate_link != true
      blank_slate_content = [blank_slate_content, blank_slate_link].compact.join(' ')
    end
    render partial: config.options[:partial] if config.options[:partial]

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

  # Overridden to render extra controls (e.g. the "Visible columns" tool) in the
  # table_tools row. Rendered before the collection, so it stays visible even on
  # empty/blank-slate results.
  def build_table_tools
    if any_table_tools?
      div class: 'table_tools' do
        build_batch_actions_selector
        build_scopes
        build_index_list
        build_additional_tools
      end
    end
  end

  # Reopening the class replaces the gem's method (no `super`), so the original
  # conditions are inlined plus our extra-tools check.
  def any_table_tools?
    active_admin_config.batch_actions.any? ||
      active_admin_config.scopes.any? ||
      active_admin_config.page_presenters[:index].try(:size).try(:>, 1) ||
      assigns[:visible_columns].is_a?(Array)
  end

  # Extra table_tools controls. Currently the visible-columns toggle (+ reset);
  # add future per-table tools here.
  def build_additional_tools
    return unless assigns[:visible_columns].is_a?(Array)

    span id: 'additional_table_tools' do
      # Icon-only (the label lives in the title attribute as a tooltip) to keep the
      # tool compact in the table_tools row.
      a href: '#', id: 'toggle_block_available_columns', class: 'table_tools_button', title: 'Visible columns' do
        span class: 'fa fa-columns'
      end
      if assigns[:visible_columns].any?
        a href: '#', id: 'reset_visible_columns', class: 'table_tools_button', title: 'Reset visible columns' do
          span class: 'fa fa-undo'
        end
      end
    end
  end
end
