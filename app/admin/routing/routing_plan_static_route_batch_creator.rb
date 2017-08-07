ActiveAdmin.register Routing::RoutingPlanStaticRouteBatchCreator do
  menu false

  actions :new, :create

  controller do
    # Redirects to index page instead of rendering updated resource
    def create
      create! { static_routes_path }
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Create batch" do
      f.input :routing_plan, collection: Routing::RoutingPlan.having_static_routes, input_html: {class: 'chosen-wide'},
              hint: I18n.t('hints.routing.routing_plan_static_route_batch_creator.routing_plan')
      f.input :network, collection: System::Network.collection, hint: I18n.t('hints.routing.routing_plan_static_route_batch_creator.network'),
              input_html: {
                class: 'chosen-wide',
                onchange: remote_chosen_request(:get, with_network_system_network_prefixes_path, {network_id: "$(this).val()"}, :routing_routing_plan_static_route_batch_creator_prefixes)
              }
      f.input :prefixes, as: :text, hint: I18n.t('hints.routing.routing_plan_static_route_batch_creator.prefixes')
      f.input :priority, input_html: {value: 100},
              hint: I18n.t('hints.routing.routing_plan_static_route_batch_creator.priority')
      f.input :vendors, collection: Contractor.vendors, input_html: {class: 'chosen-sortable', multiple: true},
      #f.input :vendors, collection: Contractor.vendors, input_html: {multiple: true},
              hint: I18n.t('hints.routing.routing_plan_static_route_batch_creator.vendors')
    end
    f.actions do
      action(:submit)
      #link_to("cancel",static_routes_path)
    end

  end

end