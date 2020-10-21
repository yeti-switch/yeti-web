# frozen_string_literal: true

ActiveAdmin.register Pop do
  menu parent: %w[System Components], priority: 10
  config.batch_actions = false

  acts_as_clone

  permit_params :id, :name

  filter :id
  filter :name

  index do
    id_column
    actions
    column :name
  end

  form do |f|
    f.inputs do
      f.input :id
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
    end
    active_admin_comments
  end
end
