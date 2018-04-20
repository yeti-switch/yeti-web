ActiveAdmin.register Routing::RateplanDuplicator do
  menu false

  actions :new, :create

  act_as_clone_helper_for Rateplan

  controller do
    # Redirects to index page instead of rendering updated resource
    def create
      create! { rateplans_path }
    end

  end

  sidebar 'Original rateplan', only: [:new, :create] do
    attributes_table_for Rateplan.find(resource.id) do
      row :id
      row :name
      row :profit_control_mode
      row "Destinations count" do |r|
        r.destinations.count
      end
    end
  end

  permit_params :id, :name, :profit_control_mode_id, send_quality_alarms_to: []

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "Copy rateplan" do
      f.input :id, as: :hidden
      f.input :name
      f.input :profit_control_mode_id, collection: Routing::RateProfitControlMode.all
      f.input :send_quality_alarms_to, as: :select, input_html: {class: 'chosen-sortable', multiple: true}, collection: Billing::Contact.collection
    end
    f.actions do
      action(:submit)
      #link_to("cancel",static_routes_path)
    end

  end

end
