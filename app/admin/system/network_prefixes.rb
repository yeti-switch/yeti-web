# frozen_string_literal: true

ActiveAdmin.register System::NetworkPrefix do
  actions :all
  menu parent: 'System', label: 'Network Prefixes', priority: 131
  config.batch_actions = false

  acts_as_export :id,
                 :prefix, :number_min_length, :number_max_length,
                 [:country_name, proc { |row| row.country.try(:name) }],
                 [:network_name, proc { |row| row.network.try(:name) }],
                 :uuid

  permit_params :prefix, :country_id, :network_id, :number_min_length, :number_max_length

  includes :country, :network

  collection_action :prefix_hint do
    render plain: System::NetworkPrefix.prefix_hint(params[:prefix])
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :prefix
  filter :country, input_html: { class: 'chosen' }
  association_ajax_filter :network_id_eq,
                          label: 'Network',
                          scope: -> { System::Network.order(:name) },
                          path: '/system_networks/search'
  filter :network_type_id_eq,
         label: 'Network Type',
         as: :select,
         input_html: { class: 'chosen' },
         collection: -> { System::NetworkType.collection }
  filter :number_contains
  filter :number_min_length
  filter :number_max_length

  index do
    id_column
    column :prefix
    column :number_min_length
    column :number_max_length
    column :country, sortable: 'countries.name'
    column :network, sortable: 'networks.name'
    column :uuid
  end

  show do
    attributes_table do
      row :id
      row :prefix
      row :number_min_length
      row :number_max_length
      row :country
      row :network
      row :uuid
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :prefix
      f.input :number_min_length
      f.input :number_max_length
      f.input :country, input_html: { class: 'chosen' }
      f.association_ajax_input :network_id,
                               label: 'Network',
                               scope: System::Network.order(:name),
                               path: '/system_networks/search'
    end
    f.actions
  end
end
