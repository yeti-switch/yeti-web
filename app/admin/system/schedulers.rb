# frozen_string_literal: true

ActiveAdmin.register System::Scheduler do
  menu parent: %w[System], priority: 10
  config.batch_actions = false

  acts_as_clone

  acts_as_export :id,
                 :name,
                 :enabled,
                 :use_reject_calls

  permit_params :id, :name, :enabled, :use_reject_calls

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
    column :current_state
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :enabled
      f.input :use_reject_calls
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :enabled
      row :use_reject_calls
      row :current_state
    end
    active_admin_comments
  end
end
