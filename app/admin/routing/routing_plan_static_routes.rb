# frozen_string_literal: true

ActiveAdmin.register Routing::RoutingPlanStaticRoute, as: 'Static Route' do
  menu parent: 'Routing', label: 'Routing plan static routes', priority: 53
  config.sort_order = 'priority_desc'

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('Routing::RoutingPlanStaticRoute')
  acts_as_async_update BatchUpdateForm::RoutingPlanStaticRoute

  acts_as_good_job_lock

  includes :vendor, :routing_plan, network_prefix: %i[country network]

  permit_params :routing_plan_id, :prefix, :priority, :weight, :vendor_id

  filter :id
  filter :routing_plan, collection: -> { Routing::RoutingPlan.having_static_routes }, input_html: { class: 'chosen' }
  filter :prefix
  filter :network_prefix_country_id_eq,
         as: :select,
         label: 'Country',
         input_html: { class: 'chosen' },
         collection: -> { System::Country.order(:name) }

  association_ajax_filter :network_prefix_network_id_eq,
                          label: 'Network',
                          scope: -> { System::Network.order(:name) },
                          path: '/system_networks/search'
  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }

  # after_build do |resource|
  #   from = begin
  #     referer = request.env["HTTP_REFERER"] && URI.parse(request.env["HTTP_REFERER"])
  #     Rack::Utils.parse_nested_query(referer.try(:query)).fetch('q', {}).with_indifferent_access
  #   end
  #   resource.vendor_id = from[:vendor_id_eq] if from.any?
  #   resource.routing_plan_id = from[:routing_plan_id_eq] if from.any?
  # end

  action_item :batch_create do
    link_to('Batch create', new_routing_plan_static_route_batch_creator_path)
  end

  index do
    selectable_column
    id_column
    actions
    column :routing_plan
    column :prefix
    column :country, sortable: 'countries.name' do |row|
      auto_link row.network_prefix&.country
    end
    column :network, sortable: 'networks.name' do |row|
      auto_link row.network_prefix&.network
    end
    column :priority
    column :weight
    column :vendor
  end

  show do |_s|
    attributes_table do
      row :id
      row :routing_plan
      row :prefix
      row :country
      row :network
      row :priority
      row :weight
      row :vendor
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :routing_plan, collection: Routing::RoutingPlan.having_static_routes, input_html: { class: 'chosen' }
      f.input :prefix, input_html: { class: :prefix_detector }, hint: f.object.network_details_hint
      f.input :priority
      f.input :weight
      f.contractor_input :vendor_id, label: 'Vendor', path_params: { q: { vendor_eq: true } }
    end
    f.actions
  end
end
