ActiveAdmin.register Report::IntervalCdr, as: 'ReportIntervalCdr' do
  menu parent: "Reports", label: "Interval Cdr report", priority: 20
  config.batch_actions = true

  actions :index, :destroy, :create, :new

  permit_params :date_start, :date_end, :interval_length, :filter, :aggregator_id, :aggregate_by,
                :group_by, group_by_fields: [], send_to: []

  controller do
    def scoped_collection
      super.includes(:aggregation_function)
    end
  end

  report_scheduler Report::IntervalCdrScheduler

  index do
    selectable_column
    id_column
    actions  do |row|
      link_to 'Data', report_interval_cdr_interval_items_path(row)
    end
    column :created_at
    column :date_start
    column :date_end
    column :interval_length
    column :filter
    column :group_by
    column :aggregation
  end

  form do |f|
    f.inputs do
      f.input :date_start, as: :date_time_picker, wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
      f.input :date_end, as: :date_time_picker
      f.input :interval_length,
              as: :select, collection: [["5 Min", 5], ["10 Min", 10], ["30 Min", 30], ["1 Hour", 60], ["6 Hours", 360], ["1 Day", 1440]]
      f.input :aggregation_function
      f.input :aggregate_by,
              as: :select, input_html: {class: 'chosen'}, collection: Report::IntervalCdr::CDR_AGG_COLUMNS
      f.input :filter
      f.input :group_by_fields,
              as: :select, input_html: {class: 'chosen', multiple: true}, collection: Report::IntervalCdr::CDR_COLUMNS
      f.input :send_to, as: :select, input_html: {class: 'chosen', multiple: true}, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  filter :date_start, as: :date_time_range
  filter :date_end, as: :date_time_range
  filter :created_at, as: :date_time_range

end

