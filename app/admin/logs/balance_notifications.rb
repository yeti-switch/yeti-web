# frozen_string_literal: true

ActiveAdmin.register Log::BalanceNotification do
  menu parent: 'Logs', priority: 160, label: 'Balance notifications'

  actions :index
  config.batch_actions = false

  controller do
    def scoped_collection
      super.preload(:account)
    end
  end

  filter :id
  account_filter :account_id_eq
  filter :event_id_eq,
         as: :select,
         input_html: { class: 'chosen' },
         collection: Log::BalanceNotification::CONST::EVENTS

  index do
    column :id
    column :account
    column :event
    column :account_balance
    column :balance_low_threshold
    column :balance_high_threshold
    column :created_at
  end

  filter :id
end
