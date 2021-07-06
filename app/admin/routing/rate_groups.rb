# frozen_string_literal: true

ActiveAdmin.register Routing::RateGroup do
  menu parent: 'Routing', label: 'Rate Groups', priority: 42

  acts_as_audit
  acts_as_clone_with_helper helper: Routing::RateGroupDuplicatorForm, name: 'Copy with destinations'
  acts_as_safe_destroy
  acts_as_export :id, :name
  acts_as_import resource_class: Importing::RateGroup

  filter :id
  filter :name

  permit_params :name

  index do
    selectable_column
    id_column
    actions
    column :name
    column :external_id
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :external_id
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name
    end
    f.actions
  end
end
