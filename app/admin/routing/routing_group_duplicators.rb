# frozen_string_literal: true

ActiveAdmin.register Routing::RoutingGroupDuplicatorForm do
  menu false

  actions :new, :create

  act_as_clone_helper_for RoutingGroup

  permit_params :id, :name

  controller do
    # Redirects to index page instead of rendering updated resource
    def create
      create! { routing_groups_path }
    end
  end

  sidebar 'Original routing group', only: %i[new create] do
    attributes_table_for RoutingGroup.find(resource.id) do
      row :id
      row :name
      row 'Destinations count' do |r|
        r.dialpeers.count
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Copy Routing Group' do
      f.input :id, as: :hidden
      f.input :name
    end
    f.actions do
      action(:submit)
      # link_to("cancel",static_routes_path)
    end
  end
end
