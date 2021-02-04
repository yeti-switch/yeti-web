# frozen_string_literal: true

ActiveAdmin.register Routing::RoutingPlanStaticRouteBatchCreatorForm do
  menu false

  actions :new, :create

  controller do
    # Redirects to index page instead of rendering updated resource
    def create
      create! { static_routes_path }
    end
  end

  permit_params :routing_plan, :network, :prefixes, :priority, :weight, vendors: []

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Create batch' do
      f.input :routing_plan, collection: Routing::RoutingPlan.having_static_routes, input_html: { class: 'chosen-wide' }
      f.input :network, collection: System::Network.collection, input_html: {
        class: 'chosen-wide',
        onchange: remote_chosen_request(:get, with_network_system_network_prefixes_path, { network_id: '$(this).val()' }, :routing_routing_plan_static_route_batch_creator_prefixes)
      }
      f.input :prefixes, as: :text, hint: 'Enter prefix OR choose Network. You can enter multiple prefixes separated by comma.'
      f.input :priority, input_html: { value: 100 }
      f.input :weight, input_html: { value: 100 }
      f.input :vendors, collection: Contractor.vendors, input_html: { class: 'chosen-sortable', multiple: true },
                        # f.input :vendors, collection: Contractor.vendors, input_html: {multiple: true},
                        hint: 'Priority will be decremented on 5 for each next Vendor'
    end
    f.actions do
      action(:submit)
      # link_to("cancel",static_routes_path)
    end
  end
end
