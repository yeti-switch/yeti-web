# frozen_string_literal: true

ActiveAdmin.register Equipment::StirShaken::TrustedRepository do
  menu parent: %w[Equipment STIR/SHAKEN], label: 'Trusted repositories', priority: 10
  config.batch_actions = false

  acts_as_clone

  permit_params :id, :url_pattern, :validate_https_certificate

  filter :id
  filter :url_pattern

  index do
    id_column
    actions
    column :url_pattern
    column :validate_https_certificate
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :url_pattern
      f.input :validate_https_certificate
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :url_pattern
      row :validate_https_certificate
      row :updated_at
    end
    active_admin_comments
  end
end
