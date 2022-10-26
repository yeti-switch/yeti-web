class RemoveRedundantColumnsFromBalanceNotification < ActiveRecord::Migration[6.1]
  def up
    execute 'DELETE FROM logs.balance_notifications'

    remove_column 'logs.balance_notifications', :action
    remove_column 'logs.balance_notifications', :direction
    remove_column 'logs.balance_notifications', :data
    remove_column 'logs.balance_notifications', :is_processed
    remove_column 'logs.balance_notifications', :processed_at

    add_column 'logs.balance_notifications', :account_id, :integer, null: false
    add_column 'logs.balance_notifications', :event_id, :integer, limit: 2, null: false
    add_column 'logs.balance_notifications', :account_balance, :decimal, null: false
    add_column 'logs.balance_notifications', :balance_low_threshold, :decimal
    add_column 'logs.balance_notifications', :balance_high_threshold, :decimal

    add_index 'logs.balance_notifications', :account_id, name: 'balance_notifications_account_id_idx'
  end

  def down
    execute 'DELETE FROM logs.balance_notifications'

    remove_column 'logs.balance_notifications', :account_id
    remove_column 'logs.balance_notifications', :event_id
    remove_column 'logs.balance_notifications', :account_balance
    remove_column 'logs.balance_notifications', :balance_low_threshold
    remove_column 'logs.balance_notifications', :balance_high_threshold

    add_column 'logs.balance_notifications', :action, :string
    add_column 'logs.balance_notifications', :direction, :string
    add_column 'logs.balance_notifications', :data, :json
    add_column 'logs.balance_notifications', :is_processed, :boolean, null: false, default: false
    add_column 'logs.balance_notifications', :processed_at, :timestamp
  end
end
