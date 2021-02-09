# frozen_string_literal: true

ActiveAdmin.register Routing::RateGroupDuplicatorForm, as: 'Routing Rate Group Duplicator' do
  menu false

  actions :new, :create

  act_as_clone_helper_for Routing::RateGroup

  permit_params :id, :name

  controller do
    # Redirects to index page instead of rendering updated resource
    def create
      create! { routing_rate_groups_path }
    end
  end

  sidebar 'Original Rate Group', only: %i[new create] do
    attributes_table_for Routing::RateGroup.find(resource.id) do
      row :id
      row :name
      row 'Destinations count' do |r|
        r.destinations.count
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs 'Copy Rate Group' do
      f.input :id, as: :hidden
      f.input :name
    end
    f.actions do
      action(:submit)
      # link_to("cancel",static_routes_path)
    end
  end
end
