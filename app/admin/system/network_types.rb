# frozen_string_literal: true

ActiveAdmin.register System::NetworkType do
  actions :all
  menu parent: 'System', label: 'Network Types', priority: 132
  config.batch_actions = false
  permit_params :name

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :name

  index do
    id_column
    column :name
    column :uuid
  end

  show do
    attributes_table do
      row :id
      row :name
      row :uuid
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
    end
    f.actions
  end
end
