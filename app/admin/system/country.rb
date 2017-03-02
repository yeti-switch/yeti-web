ActiveAdmin.register System::Country do
  actions :index,:show
  menu parent: "System", label: "Countries", priority: 120
  config.batch_actions = false

  filter :id
  filter :name
  filter :iso2

  collection_action :get_networks do
    country =  System::Country.find(params[:country_id])
    @networks = country.networks
    render text:  view_context.options_from_collection_for_select(@networks, :id, :name)
  end

  index do
    id_column
    column :name
    column :iso2
  end

end