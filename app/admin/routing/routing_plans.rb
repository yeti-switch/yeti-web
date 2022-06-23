# frozen_string_literal: true

ActiveAdmin.register Routing::RoutingPlan do
  menu parent: 'Routing', label: 'Routing plans', priority: 50
  decorate_with RoutingPlanDecorator

  acts_as_audit
  acts_as_clone links: [:routing_groups]
  acts_as_safe_destroy
  acts_as_async_destroy('Routing::RoutingPlan')
  acts_as_async_update BatchUpdateForm::RoutingPlan

  acts_as_delayed_job_lock
  acts_as_export :id,
                 :name,
                 [:sorting_name, proc { |row| row.sorting.try(:name) || '' }],
                 :use_lnp,
                 :rate_delta_max,
                 :max_rerouting_attempts,
                 :validate_dst_number_format,
                 :validate_dst_number_network

  permit_params :name, :sorting_id, :use_lnp, :rate_delta_max, :max_rerouting_attempts,
                :validate_dst_number_format, :validate_dst_number_network,
                routing_group_ids: []

  includes :sorting, :routing_groups

  filter :id
  filter :name
  filter :sorting
  filter :use_lnp, as: :select, collection: [['Yes', true], ['No', false]]
  account_filter :customers_auths_account_id_eq, label: 'Assigned to account', path_params: { q: { contractor_customer_eq: true } }
  filter :rate_delta_max
  filter :max_rerouting_attempts
  filter :routing_groups, input_html: { class: 'chosen' }, collection: proc { RoutingGroup.pluck(:name, :id) }

  index do
    selectable_column
    id_column
    actions
    column :name
    column :sorting, sortable: 'sortings.name'
    column 'Use LNP', :use_lnp
    column :rate_delta_max
    column :max_rerouting_attempts
    column 'Routing groups', :routing_groups_links
    column :validate_dst_number_format
    column :validate_dst_number_network
  end

  show do
    # tabs do
    #   tab "Details" do
    attributes_table do
      row :id
      row :name
      row :sorting
      row :use_lnp
      row :rate_delta_max
      row :max_rerouting_attempts
      row 'Routing groups' do |r|
        r.routing_groups_links(newline: true)
      end
      row :validate_dst_number_format
      row :validate_dst_number_network
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :sorting
      f.input :use_lnp
      f.input :rate_delta_max
      f.input :max_rerouting_attempts
      f.input :routing_groups, input_html: { class: 'chosen-sortable', multiple: true }
      f.input :validate_dst_number_format
      f.input :validate_dst_number_network
    end
    f.actions
  end

  sidebar :links, only: %i[show edit] do
    ul do
      li do
        link_to 'Customer Auths', customers_auths_path(q: { routing_plan_id_eq: params[:id] })
      end
      li do
        link_to 'CDR list', cdrs_path(q: { routing_plan_id_eq: params[:id] })
      end
      if resource.use_static_routes?
        li do
          link_to "Static routes(#{resource.static_routes.count})", static_routes_path(q: { routing_plan_id_eq: params[:id] })
        end
      end
    end
  end
end
