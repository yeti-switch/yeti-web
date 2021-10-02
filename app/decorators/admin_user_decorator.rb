# frozen_string_literal: true

class AdminUserDecorator < ApplicationDecorator
  def ssh_key_tag
    status_tag(model.ssh_key.present?.to_s, class: model.ssh_key.present? ? :ok : nil)
  end

  def roles_list
    model.roles.join(', ')
  end

  def pretty_visible_columns
    h.pre_wrap_json(model.visible_columns)
  end

  def pretty_per_page
    h.pre_wrap_json(model.per_page)
  end

  def pretty_saved_filters
    h.pre_wrap_json(model.saved_filters)
  end

  def has_allowed_ips
    if model.allowed_ips.nil?
      status_tag(:no)
    else
      status_tag(:yes)
    end
  end

  def pretty_allowed_ips
    return if model.allowed_ips.nil?

    pre_wrap model.allowed_ips.join("\n")
  end
end
