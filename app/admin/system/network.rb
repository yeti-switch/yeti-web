# frozen_string_literal: true

ActiveAdmin.register System::Network do
  actions :all
  menu parent: 'System', label: 'Networks', priority: 130
  config.batch_actions = false
  permit_params :name

  filter :id
  filter :name

  index do
    id_column
    actions
    column :name
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
    end
    f.actions
  end
end
