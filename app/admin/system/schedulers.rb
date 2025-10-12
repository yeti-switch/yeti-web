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

  permit_params :id, :name, :enabled, :use_reject_calls, :timezone,
                ranges_attributes: [
                  :id, :from_time, :till_time, :_destroy, weekdays: []
                ]

  filter :id
  filter :name
  filter :enabled
  filter :use_reject_calls
  filter :timezone

  index do
    id_column
    actions
    column :name
    column :enabled
    column :current_state, &:current_state_badge
    column :use_reject_calls
    column :timezone
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs form_title do
      f.input :name
      f.input :enabled
      f.input :use_reject_calls
      f.input :timezone,
             as: :select,
             input_html: { class: 'chosen' },
             collection: Yeti::TimeZoneHelper.all
    end

    f.inputs 'Time intervals when traffic will be blocked' do
      f.has_many :ranges do |t|
        t.input :weekdays,
                as: :select,
                collection: System::SchedulerRange::WEEKDAYS.invert,
                input_html: { class: :chosen, multiple: true }

        t.input :from_time, as: :string, hint: 'Time in format HH24:MM:SS or HH24:MM. Leave empty for start of the day'
        t.input :till_time, as: :string, hint: 'Time in format HH24:MM:SS or HH24:MM. Leave empty for end of the day. Should be greater than from_time.'
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
      row :current_state, &:current_state_badge
      row :use_reject_calls
      row :timezone
    end

    panel 'Time intervals when traffic will be blocked' do
      table_for s.ranges.order('id') do
        column :weekdays, &:weekdays_names
        column :from_time
        column :till_time
      end
    end

    active_admin_comments
  end

  sidebar :links, only: %i[show edit] do
    ul do
      li do
        link_to 'Customer Auths', customers_auths_path(q: { scheduler_id_eq: params[:id] })
      end
      li do
        link_to 'Destinations', destinations_path(q: { scheduler_id_eq: params[:id] })
      end
      li do
        link_to 'Dialpeers', dialpeers_path(q: { scheduler_id_eq: params[:id] })
      end
      li do
        link_to 'Gateways', gateways_path(q: { scheduler_id_eq: params[:id] })
      end
    end
  end
end
