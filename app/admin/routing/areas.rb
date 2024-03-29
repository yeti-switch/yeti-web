# frozen_string_literal: true

ActiveAdmin.register Routing::Area do
  menu parent: 'Routing', priority: 251, label: 'Areas'

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  permit_params :name

  index do
    selectable_column
    id_column
    actions
    column :name
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name
    end
    f.actions
  end

  filter :id
  filter :name
end
