# frozen_string_literal: true

ActiveAdmin.register Routing::RoutingPlanStaticRouteBatchCreatorForm, as: 'Routing Plan Static Route Batch Creator' do
  menu false

  actions :new, :create

  controller do
    # Redirects to index page instead of rendering updated resource
    def create
      create! { static_routes_path }
    end
  end

  permit_params :routing_plan, :prefixes, :priority, :weight, vendors: []

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs 'Create batch' do
      f.input :routing_plan, collection: Routing::RoutingPlan.having_static_routes, input_html: { class: 'tom-select-wide' }

      f.input :prefixes, as: :text, hint: 'You can enter multiple prefixes separated by comma.'
      f.input :priority, input_html: { value: 100 }
      f.input :weight, input_html: { value: 100 }

      f.contractor_input :vendors, label: 'Vendors', path_params: { q: { vendor_eq: true } }, multiple: true,
                                   hint: 'Priority will be decremented on 5 for each next Vendor'
    end
    f.actions do
      action(:submit)
      # link_to("cancel",static_routes_path)
    end
  end
end
