# frozen_string_literal: true

ActiveAdmin.register Report::VendorTraffic, as: 'VendorTraffic' do
  menu parent: 'Reports', label: 'Vendor traffic', priority: 12
  config.batch_actions = true
  actions :index, :destroy, :create, :new

  permit_params :date_start, :date_end,
                :vendor_id, send_to: []

  controller do
    def scoped_collection
      super.preload(:vendor)
    end
  end

  report_scheduler Report::VendorTrafficScheduler

  index do
    selectable_column
    id_column
    actions do |row|
      link_to 'View', vendor_traffic_vendor_traffic_data_path(row)
    end
    column :created_at
    column :vendor
    column :date_start
    column :date_end
  end

  form do |f|
    f.inputs do
      f.input :date_start, as: :date_time_picker, wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
      f.input :date_end, as: :date_time_picker
      f.input :vendor, as: :select, input_html: { class: 'chosen' }, collection: Contractor.where(vendor: true)
      f.input :send_to, as: :select, input_html: { class: 'chosen', multiple: true }, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  filter :date_start, as: :date_time_range
  filter :date_end, as: :date_time_range
  filter :created_at, as: :date_time_range
  filter :vendor,
         input_html: { class: 'chosen-ajax', 'data-path': '/contractors/search?q[vendor_eq]=true' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:vendor_id_eq]
           resource_id ? Contractor.where(id: resource_id) : []
         }
end
