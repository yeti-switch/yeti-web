# frozen_string_literal: true

ActiveAdmin.register Report::IntervalCdr, as: 'ReportIntervalCdr' do
  menu parent: 'Reports', label: 'Interval Cdr report', priority: 20
  config.batch_actions = true

  actions :index, :destroy, :create, :new

  includes :aggregation_function

  controller do
    def build_new_resource
      Report::IntervalCdrForm.new(*resource_params)
    end
  end

  report_scheduler Report::IntervalCdrScheduler

  filter :id
  boolean_filter :completed
  filter :date_start, as: :date_time_range
  filter :date_end, as: :date_time_range
  filter :created_at, as: :date_time_range
  filter :interval_length

  filter :aggregate_by,
         as: :select,
         input_html: { class: 'chosen' },
         collection: Report::IntervalCdr::CDR_AGG_COLUMNS

  filter :aggregation_function,
         as: :select,
         input_html: { class: 'chosen' },
         collection: proc { Report::IntervalAggregator.pluck(:name, :id) }

  index do
    selectable_column
    id_column
    actions do |row|
      link_to 'Data', report_interval_cdr_interval_items_path(row)
    end
    column :completed
    column :created_at
    column :date_start
    column :date_end
    column :interval_length
    column :filter
    column :group_by
    column :aggregation
  end

  permit_params :date_start,
                :date_end,
                :interval_length,
                :filter,
                :aggregator_id,
                :aggregate_by,
                group_by: [],
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

      f.input :interval_length,
              as: :select,
              input_html: { class: 'chosen' },
              collection: Report::IntervalCdr::INTERVALS.map { |num, name| [name, num] }

      f.input :aggregator_id,
              label: 'Aggregation function',
              as: :select,
              input_html: { class: 'chosen' },
              collection: Report::IntervalAggregator.pluck(:name, :id)

      f.input :aggregate_by,
              as: :select,
              input_html: { class: 'chosen' },
              collection: Report::IntervalCdr::CDR_AGG_COLUMNS

      f.input :filter

      f.input :group_by,
              as: :select,
              input_html: { class: 'chosen', multiple: true },
              collection: Report::IntervalCdr::CDR_COLUMNS

      f.input :send_to,
              as: :select,
              input_html: { class: 'chosen', multiple: true },
              collection: Billing::Contact.collection,
              hint: f.object.send_to_hint
    end
    f.actions
  end
end
