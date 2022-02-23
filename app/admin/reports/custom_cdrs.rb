# frozen_string_literal: true

ActiveAdmin.register Report::CustomCdr, as: 'CustomCdr' do
  menu parent: 'Reports', label: 'Custom Cdr report', priority: 10
  config.batch_actions = true
  actions :index, :destroy, :create, :new

  permit_params :date_start,
                :date_end,
                :customer_id,
                :filter,
                send_to: [],
                group_by: []

  controller do
    def build_new_resource
      CustomCdrReportForm.new(*resource_params)
    end

    def scoped_collection
      super.preload(:customer)
    end

    def create
      create!
    end
  end

  report_scheduler Report::CustomCdrScheduler

  index do
    selectable_column
    id_column
    actions do |row|
      link_to 'View', custom_cdr_custom_items_path(row)
    end
    column :completed
    column :created_at
    column :date_start
    column :date_end
    column :customer
    column :filter
    column :group_by
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :date_start, as: :date_time_picker, wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
      f.input :date_end, as: :date_time_picker
      f.contractor_input :customer_id, label: 'Customer', path_params: { q: { customer_eq: true } }
      f.input :filter
      f.input :group_by,
              as: :select,
              input_html: { class: 'chosen-sortable', multiple: true },
              collection: Report::CustomData::CDR_COLUMNS
      f.input :send_to,
              as: :select,
              input_html: { class: 'chosen-sortable', multiple: true },
              collection: Billing::Contact.collection,
              hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  # boolean_filter :completed
  filter :date_start, as: :date_time_range
  filter :date_end, as: :date_time_range
  filter :created_at, as: :date_time_range
  contractor_filter :customer_id_eq, label: 'Customer', path_params: { q: { customer_eq: true } }
end
