# frozen_string_literal: true

ActiveAdmin.register RoutingGroup do
  menu parent: 'Routing', priority: 50

  acts_as_audit
  acts_as_clone_with_helper helper: Routing::RoutingGroupDuplicator, name: 'Copy with dialpeers'
  acts_as_safe_destroy
  acts_as_export :id, :name
  acts_as_import resource_class: Importing::RoutingGroup

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

  sidebar :links, only: %i[show edit] do
    ul do
      li do
        link_to 'Dialpeers', dialpeers_path(q: { routing_group_id_eq: params[:id] })
      end
      li do
        link_to 'CDR list', cdrs_path(q: { routing_group_id_eq: params[:id] })
      end
    end
  end
end
