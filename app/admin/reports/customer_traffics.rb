# frozen_string_literal: true

ActiveAdmin.register Report::CustomerTraffic, as: 'CustomerTraffic' do
  menu parent: 'Reports', label: 'Customer traffic', priority: 10
  config.batch_actions = true
  actions :index, :destroy, :create, :new

  controller do
    def build_new_resource
      Report::CustomerTrafficForm.new(*resource_params)
    end

    def scoped_collection
      super.preload(:customer)
    end
  end

  report_scheduler Report::CustomerTrafficScheduler

  filter :id
  boolean_filter :completed
  filter :date_start, as: :date_time_range
  filter :date_end, as: :date_time_range
  filter :created_at, as: :date_time_range

  contractor_filter :customer_id_eq,
                    label: 'Customer',
                    path_params: { q: { customer_eq: true } }

  index do
    selectable_column
    id_column
    actions do |row|
      link_to('By vendors', customer_traffic_customer_traffic_data_by_vendors_path(row), class: :member_link) +
        link_to('By destinations', customer_traffic_customer_traffic_data_by_destinations_path(row), class: :member_link) +
        link_to('By vendors and destinations', customer_traffic_customer_traffic_data_fulls_path(row))
    end
    column :completed
    column :created_at
    column :customer
    column :date_start
    column :date_end
  end

  permit_params :date_start,
                :date_end,
                :customer_id,
                send_to: []

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :date_start,
              as: :date_time_picker,
              wrapper_html: {
                class: 'datetime_preset_pair',
                data: { show_time: 'true' }
              }

      f.input :date_end,
              as: :date_time_picker

      f.contractor_input :customer_id,
                         label: 'Customer',
                         path_params: { q: { customer_eq: true } }

      f.input :send_to,
              as: :select,
              input_html: { class: 'chosen', multiple: true },
              collection: Billing::Contact.collection,
              hint: f.object.send_to_hint
    end
    f.actions
  end
end
