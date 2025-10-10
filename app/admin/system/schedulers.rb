# frozen_string_literal: true

ActiveAdmin.register System::Scheduler do
  menu parent: %w[System], priority: 10
  config.batch_actions = false

  decorate_with SystemSchedulerDecorator

  acts_as_clone duplicates: [:ranges]

  acts_as_export :id,
                 :name,
                 :enabled,
                 :use_reject_calls

  permit_params :id, :name, :enabled, :use_reject_calls,
                ranges_attributes: [
                  :id, :from_time, :till_time, :_destroy, weekdays: []
                ]

  filter :id
  filter :name
  filter :enabled
  filter :use_reject_calls

  index do
    id_column
    actions
    column :name
    column :enabled
    column :use_reject_calls
    column :current_state, &:current_state_badge
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs form_title do
      f.input :name
      f.input :enabled
      f.input :use_reject_calls
    end

    f.inputs 'Time intervals when traffic will be blocked' do
      f.has_many :ranges do |t|
        t.input :weekdays,
                as: :select,
                collection: System::SchedulerRange::WEEKDAYS.invert,
                input_html: { class: :chosen, multiple: true }

        t.input :from_time
        t.input :till_time
        t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless t.object.new_record?
      end
    end

    f.actions
  end

  show do |s|
    attributes_table do
      row :id
      row :name
      row :enabled
      row :use_reject_calls
      row :current_state, &:current_state_badge
    end

    panel 'Time intervals when traffic will be blocked' do
      table_for s.ranges.order('id') do
        column :weekdays, &:weekdays_names
        column :from_time do |x|
          x.from_time.strftime '%H:%M'
        end
        column :till_time do |x|
          x.till_time.strftime '%H:%M'
        end
      end
    end

    active_admin_comments
  end
end
