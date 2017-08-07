ActiveAdmin.register Routing::RoutingPlanStaticRoute, as: "Static Route" do
  menu parent: "Routing", label: "Routing plan static routes", priority: 53
  config.sort_order = 'priority_desc'

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy


  includes :vendor, :routing_plan, network_prefix: [:country, :network]

  permit_params :routing_plan_id, :prefix, :priority, :vendor_id

  batch_action :change_priority, priority: 1, form: ->{
      {
          priority: 'text'
      }
                                 } do |ids, inputs|
    begin
      #TODO fix. Papertrail not used.
      count = 0
      Routing::RoutingPlanStaticRoute.transaction do
        apply_authorization_scope(scoped_collection).where(id: ids).each do |x|
          x.update(priority: inputs['priority'])
          ++count
        end
      end
      flash[:notice] = "#{count}/#{ids.count} records updated ##{inputs['group']}"
    rescue StandardError => e
      flash[:error] = e.message
      Rails.logger.warn "UCS#batch_assign_to_group raise exception: #{e.message}\n#{e.backtrace.join("\n")}"
    end
      redirect_to :back
  end

  batch_action :change_vendor, priority: 2, form: ->{
                                 {
                                     vendor: Contractor.vendors.order(:name).pluck(:name,:id)
                                 }
                               } do |ids, inputs|
    begin
      count=0
      Routing::RoutingPlanStaticRoute.transaction do
        apply_authorization_scope(scoped_collection).where(id: ids).each do |x|
          x.update(vendor_id: inputs['vendor'])
          ++count
        end
      end
      flash[:notice] = "#{count}/#{ids.count} records updated ##{inputs['group']}"
    rescue StandardError => e
      flash[:error] = e.message
      Rails.logger.warn "UCS#batch_assign_to_group raise exception: #{e.message}\n#{e.backtrace.join("\n")}"
    end
    redirect_to :back
  end

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

  action_item do
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
      f.input :routing_plan, collection: Routing::RoutingPlan.having_static_routes, input_html: {class: 'chosen'},
              hint: I18n.t('hints.routing.routing_plan_static_route.routing_plan')
      f.input :prefix, input_html: {class: :prefix_detector} , hint: f.object.network_details_hint
      f.input :priority, hint: I18n.t('hints.routing.routing_plan_static_route.priority')
      f.input :vendor, collection:  Contractor.vendors , input_html: {class: 'chosen', multiple: false},
              hint: I18n.t('hints.routing.routing_plan_static_route.vendor')
    end
    f.actions
  end

end
