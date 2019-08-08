# frozen_string_literal: true

ActiveAdmin.register System::NetworkPrefix do
  actions :all
  menu parent: 'System', label: 'Network Prefixes', priority: 131
  config.batch_actions = false

  permit_params :prefix, :country_id, :network_id

  controller do
    def scoped_collection
      super.eager_load(:country, :network)
    end
  end

  collection_action :search do
    render plain: System::NetworkPrefix.prefix_hint(params[:prefix])
  end

  collection_action :with_network do
    render plain: System::NetworkPrefix.prefix_list_by_network(params[:network_id].to_i)
  end

  # filter :network_prefix_country_id_eq,
  #        label: 'Country',
  #        input_html: {class: 'chosen',
  #                     onchange: remote_chosen_request(:get, 'system_countries/get_networks', {country_id: "$(this).val()"}, :q_network_prefix_network_id_eq)
  #
  #        },
  #        as: :select, collection: ->{ System::Country.all }
  #
  #
  # filter :network_prefix_network_id_eq,
  #        label: 'Network',
  #        input_html: {class: 'chosen'},
  #        as: :select,
  #        collection: -> {
  #          System::Country.find(assigns["search"].network_prefix_country_id_eq).networks rescue []
  #
  #        }
  filter :id
  filter :prefix
  filter :country, input_html: { class: 'chosen' }
  filter :network, input_html: { class: 'chosen' }
  filter :number_contains

  index do
    id_column
    actions
    column :prefix
    column :country, sortable: 'countries.name'
    column :network, sortable: 'networks.name'
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :prefix
      f.input :country, input_html: { class: 'chosen' }
      f.input :network, input_html: { class: 'chosen' }
    end
    f.actions
  end
end
