ActiveAdmin.register Routing::RoutingPlanStaticRoute, as: "Static Route" do
  menu parent: "Routing", label: "Routing plan static routes", priority: 53
  config.sort_order = 'priority_desc'

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('Routing::RoutingPlanStaticRoute')
  acts_as_async_update('Routing::RoutingPlanStaticRoute',
                       lambda do
                         {
                           routing_plan_id: Routing::RoutingPlan.pluck(:name, :id),
                           prefix: 'text',
                           priority: 'text',
                           vendor_id: Contractor.vendors.pluck(:name, :id)
                         }
                       end)

  acts_as_delayed_job_lock


  includes :vendor, :routing_plan, network_prefix: [:country, :network]

  permit_params :routing_plan_id, :prefix, :priority, :vendor_id

  filter :id
  filter :routing_plan, collection: -> { Routing::RoutingPlan.having_static_routes }, input_html: {class: 'chosen'}
  filter :prefix
  filter :country, input_html: {class: 'chosen'}
  filter :network, input_html: {class: 'chosen'}
  filter :vendor, collection: -> { Contractor.vendors }, input_html: {class: 'chosen'}



  # after_build do |resource|
  #   from = begin
  #     referer = request.env["HTTP_REFERER"] && URI.parse(request.env["HTTP_REFERER"])
  #     Rack::Utils.parse_nested_query(referer.try(:query)).fetch('q', {}).with_indifferent_access
  #   end
  #   resource.vendor_id = from[:vendor_id_eq] if from.any?
  #   resource.routing_plan_id = from[:routing_plan_id_eq] if from.any?
  # end

  action_item :batch_create do
    link_to("Batch create",new_routing_routing_plan_static_route_batch_creator_path())
  end

  index do
    selectable_column
    id_column
    actions
    column :routing_plan
    column :prefix
    column :country, sortable: 'countries.name' do |row|
      auto_link row.network_prefix.try!(:country)
    end
    column :network, sortable: 'networks.name' do |row|
      auto_link row.network_prefix.try!(:network)
    end
    column :priority
    column :vendor
    column :updated_at do |row|
      row.versions.last.created_at
    end
    column :updated_by do |row|
      whodunit_link row.versions.last.whodunnit
    end
  end


  show do |s|
    attributes_table do
      row :id
      row :routing_plan
      row :prefix
      row :country
      row :network
      row :priority
      row :vendor
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :routing_plan, collection: Routing::RoutingPlan.having_static_routes, input_html: {class: 'chosen'}
      f.input :prefix, input_html: {class: :prefix_detector} , hint: f.object.network_details_hint
      f.input :priority
      f.input :vendor, collection:  Contractor.vendors , input_html: {class: 'chosen', multiple: false}
    end
    f.actions
  end

end
