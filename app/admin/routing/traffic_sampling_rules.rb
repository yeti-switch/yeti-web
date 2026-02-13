# frozen_string_literal: true

ActiveAdmin.register Routing::TrafficSamplingRule do
  menu parent: 'Routing', priority: 300, label: 'Traffic Sampling Rules'

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  permit_params :customers_auth_id, :customer_id, :src_prefix, :dst_prefix, :dump_level_id, :dump_rate, :recording_rate
  includes :customer, :customers_auth

  filter :id
  contractor_filter :customer_id_eq,
                    label: 'Customer',
                    path_params: { q: { customer_eq: true } }
  association_ajax_filter :customers_auth_id_eq,
                         label: 'Customers Auth',
                         scope: -> { CustomersAuth.order(:name) },
                         path: '/customers_auths/search'
  filter :src_prefix
  filter :dst_prefix

  index do
    selectable_column
    id_column
    actions
    column :customer
    column :customers_auth
    column :src_prefix
    column :dst_prefix
    column :dump_level, &:dump_level_name
    column :dump_rate
    column :recording_rate
  end

  show do |_s|
    attributes_table do
      row :id
      row :customer
      row :customers_auth
      row :src_prefix
      row :dst_prefix
      row :dump_level, &:dump_level_name
      row :dump_rate
      row :recording_rate
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.contractor_input :customer_id,
                         label: 'Customer',
                         path_params: { q: { customer_eq: true } }

      f.association_ajax_input :customers_auth_id,
                               label: 'Customers Auth',
                               scope: CustomersAuth.order(:name),
                               path: '/customers_auths/search',
                               fill_params: { customer_id_eq: f.object.customer_id },
                               fill_required: :customer_id_eq,
                               input_html: {
                                 'data-path-params': { 'q[customer_id_eq]': '.customer_id-input' }.to_json,
                                 'data-required-param': 'q[customer_id_eq]'
                               }
      f.input :src_prefix
      f.input :dst_prefix
      f.input :dump_level_id, as: :select, include_blank: false, collection: Routing::TrafficSamplingRule::DUMP_LEVELS.invert, input_html: { class: 'tom-select' }
      f.input :dump_rate
      f.input :recording_rate
    end
    f.actions
  end
end
