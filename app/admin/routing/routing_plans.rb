# frozen_string_literal: true

ActiveAdmin.register Routing::RoutingPlan do
  menu parent: 'Routing', label: 'Routing plans', priority: 49
  decorate_with RoutingPlanDecorator

  acts_as_audit
  acts_as_clone links: [:routing_groups]
  acts_as_safe_destroy
  acts_as_async_destroy('Routing::RoutingPlan')
  acts_as_async_update BatchUpdateForm::RoutingPlan

  acts_as_good_job_lock
  acts_as_export :id,
                 :name,
                 :sorting_name,
                 :use_lnp,
                 :rate_delta_max,
                 :max_rerouting_attempts,
                 :validate_dst_number_format,
                 :validate_dst_number_network,
                 :validate_src_number_format,
                 :validate_src_number_network,
                 [:src_numberlist_name, proc { |row| row.src_numberlist.try(:name) }],
                 [:dst_numberlist_name, proc { |row| row.dst_numberlist.try(:name) }]

  permit_params :name, :sorting_id, :use_lnp, :rate_delta_max, :max_rerouting_attempts,
                :validate_dst_number_format, :validate_dst_number_network,
                :validate_src_number_format, :validate_src_number_network,
                :src_numberlist_id, :dst_numberlist_id,
                routing_group_ids: []

  includes :routing_groups, :src_numberlist, :dst_numberlist

  filter :id
  filter :name
  filter :sorting_id_eq, label: 'Sorting', as: :select, collection: Routing::RoutingPlan::SORTINGS.invert
  filter :use_lnp, as: :select, collection: [['Yes', true], ['No', false]]
  account_filter :customers_auths_account_id_eq, label: 'Assigned to account', path_params: { q: { contractor_customer_eq: true } }
  filter :rate_delta_max
  filter :max_rerouting_attempts
  filter :routing_groups, input_html: { class: 'chosen' }, collection: proc { Routing::RoutingGroup.order(:name).pluck(:name, :id) }

  index do
    selectable_column
    id_column
    actions
    column :name
    column :sorting, &:sorting_name
    column 'Use LNP', :use_lnp
    column :rate_delta_max
    column :max_rerouting_attempts
    column 'Routing groups', :routing_groups_links
    column :validate_dst_number_format
    column :validate_dst_number_network
    column :validate_src_number_format
    column :validate_src_number_network
    column :src_numberlist
    column :dst_numberlist
  end

  show do
    # tabs do
    #   tab "Details" do
    attributes_table do
      row :id
      row :name
      row :sorting, &:sorting_name
      row :use_lnp
      row :rate_delta_max
      row :max_rerouting_attempts
      row 'Routing groups' do |r|
        r.routing_groups_links(newline: true)
      end
      row :validate_dst_number_format
      row :validate_dst_number_network
      row :validate_src_number_format
      row :validate_src_number_network
      row :src_numberlist
      row :dst_numberlist
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :sorting_id, as: :select, include_blank: false, collection: Routing::RoutingPlan::SORTINGS.invert
      f.input :use_lnp
      f.input :rate_delta_max
      f.input :max_rerouting_attempts
      f.input :routing_groups,
              input_html: { class: 'chosen-sortable', multiple: true },
              collection: Routing::RoutingGroup.order(:name)
      f.input :validate_dst_number_format
      f.input :validate_dst_number_network
      f.input :validate_src_number_format
      f.input :validate_src_number_network
      f.association_ajax_input :dst_numberlist_id,
                               label: 'DST Numberlist',
                               scope: Routing::Numberlist.order(:name),
                               path: '/numberlists/search'

      f.association_ajax_input :src_numberlist_id,
                               label: 'SRC Numberlist',
                               scope: Routing::Numberlist.order(:name),
                               path: '/numberlists/search'
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
