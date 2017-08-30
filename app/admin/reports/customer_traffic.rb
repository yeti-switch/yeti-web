ActiveAdmin.register Report::CustomerTraffic, as: 'CustomerTraffic' do

  menu parent: "Reports", label: "Customer traffic", priority: 10
  config.batch_actions = true
  actions :index, :destroy, :create, :new

  permit_params :date_start, :date_end,
                :customer_id, group_by: [] , send_to: []

  controller do
    def scoped_collection
      super.includes(:customer)
    end
  end

  report_scheduler Report::CustomerTrafficScheduler

  index do
    selectable_column
    id_column
    actions do |row|
      link_to('By vendors', customer_traffic_customer_traffic_data_by_vendors_path(row), class: :member_link) +
      link_to('By destinations', customer_traffic_customer_traffic_data_by_destinations_path(row), class: :member_link) +
      link_to('By vendors and destinations', customer_traffic_customer_traffic_data_fulls_path(row))
    end
    column :created_at
    column :customer
    column :date_start
    column :date_end
  end

  form do |f|
    f.inputs do
      f.input :date_start, as: :date_time_picker, wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
      f.input :date_end, as: :date_time_picker
      f.input :customer, as: :select, input_html: {class: 'chosen'}, collection: Contractor.where(customer: true)
      f.input :send_to, as: :select, input_html: {class: 'chosen', multiple: true}, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  filter :date_start, as: :date_time_range
  filter :date_end, as: :date_time_range
  filter :created_at, as: :date_time_range
  filter :customer,as: :select, input_html: {class: 'chosen'}, collection: proc { Contractor.where(customer: true) }





end

