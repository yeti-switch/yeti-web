# frozen_string_literal: true

ActiveAdmin.register Log::BalanceNotification do
  menu parent: 'Logs', priority: 160, label: 'Balance notifications'

  actions :index, :show
  config.batch_actions = false

  index do
    id_column
    column :created_at
    column :direction
    column :action
    column :is_processed
    column :processed_at
    column :data
  end

  filter :id
end
