# frozen_string_literal: true

ActiveAdmin.register Routing::RoutingGroup do
  menu parent: 'Routing', label: 'Routing groups', priority: 50

  acts_as_audit
  acts_as_clone_with_helper helper: Routing::RoutingGroupDuplicatorForm, name: 'Copy with dialpeers'
  acts_as_safe_destroy
  acts_as_export :id, :name
  acts_as_import resource_class: Importing::RoutingGroup

  filter :id
  filter :name

  permit_params :name, routing_plan_ids: []

  includes :routing_plans

  index do
    selectable_column
    id_column
    actions
    column :name
    column :routing_plans
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :routing_plans
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :routing_plans,
              input_html: { class: 'chosen-sortable', multiple: true },
              collection: Routing::RoutingPlan.order(:name)
    end
    f.actions
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
