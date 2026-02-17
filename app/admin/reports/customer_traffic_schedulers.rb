# frozen_string_literal: true

ActiveAdmin.register Report::CustomerTrafficScheduler, as: 'CustomerTrafficScheduler' do
  menu false
  config.batch_actions = false
  actions :index, :destroy, :create, :new, :show

  permit_params :customer_id, :period_id, send_to: []

  controller do
    def scoped_collection
      super.preload(:customer, :period)
    end
  end

  for_report Report::CustomerTraffic

  index do
    selectable_column
    id_column
    actions
    column :created_at
    column :period
    column :customer
    column :send_to do |r|
      r.contacts.map(&:email).sort.join(', ')
    end
    column :last_run_at
    column :next_run_at
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :period
      f.contractor_input :customer_id, label: 'Customer', path_params: { q: { customer_eq: true } }
      f.input :send_to, as: :select, input_html: { class: 'tom-select', multiple: true }, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  filter :created_at, as: :date_time_range
  contractor_filter :customer_id_eq, label: 'Customer', path_params: { q: { customer_eq: true } }

  show do |_s|
    attributes_table do
      row :id
      row :created_at
      row :period
      row :customer
      row :send_to do |r|
        r.contacts.map(&:email).sort.join(', ')
      end
      row :last_run_at
      row :next_run_at
    end
  end
end
