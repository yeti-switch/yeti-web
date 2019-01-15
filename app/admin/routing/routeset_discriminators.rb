# frozen_string_literal: true

ActiveAdmin.register Routing::RoutesetDiscriminator do
  menu parent: 'Routing', label: 'Routeset Discriminators', priority: 52

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_export :id, :name

  #  acts_as_import resource_class: Importing::RoutingGroup

  filter :id
  filter :name

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
    active_admin_comments
  end
end
