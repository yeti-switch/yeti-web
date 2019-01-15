# frozen_string_literal: true

ActiveAdmin.register Report::IntervalCdrScheduler, as: 'IntervalCdrScheduler' do
  menu false
  config.batch_actions = false

  actions :index, :destroy, :create, :new

  permit_params :period_id, :interval_length, :filter, :aggregator_id, :aggregate_by, group_by: [], send_to: []

  includes :aggregation_function

  for_report Report::IntervalCdr

  index do
    selectable_column
    id_column
    actions
    column :created_at
    column :period
    column :interval_length
    column :filter
    column :group_by
    column :aggregation
    column :send_to do |r|
      r.contacts.map(&:email).sort.join(', ')
    end
    column :last_run_at
    column :next_run_at
  end

  form do |f|
    f.inputs do
      f.input :period
      f.input :interval_length, as: :select, collection: [['5 Min', 5], ['10 Min', 10], ['30 Min', 30], ['1 Hour', 60], ['6 Hours', 360], ['1 Day', 1440]]
      f.input :aggregation_function
      f.input :aggregate_by, as: :select, input_html: { class: 'chosen' }, collection: Report::IntervalCdr::CDR_AGG_COLUMNS
      f.input :filter
      f.input :group_by, as: :select, input_html: { class: 'chosen', multiple: true }, collection: Report::IntervalCdr::CDR_COLUMNS
      f.input :send_to, as: :select, input_html: { class: 'chosen', multiple: true }, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  filter :created_at, as: :date_time_range
end
