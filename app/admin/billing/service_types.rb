# frozen_string_literal: true

ActiveAdmin.register Billing::ServiceType, as: 'ServiceType' do
  menu parent: %w[Billing Settings], label: 'Service Types', priority: 100

  permit_params :id, :name, :provisioning_class, :variables, :force_renew

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_export :id,
                 :name,
                 :provisioning_class,
                 :variables,
                 :force_renew

  filter :id
  filter :name
  filter :provisioning_class
  filter :force_renew

  index do
    selectable_column
    id_column
    actions
    column :name
    column :force_renew
    column :provisioning_class
    column :variables
  end

  show do
    attributes_table do
      row :id
      row :name
      row :force_renew
      row :provisioning_class
      row :variables
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name
      f.input :force_renew
      f.input :provisioning_class
      f.input :variables
    end
    f.actions
  end

end

