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
end
