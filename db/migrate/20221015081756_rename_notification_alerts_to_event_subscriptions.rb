class RenameNotificationAlertsToEventSubscriptions < ActiveRecord::Migration[6.1]
  def up
    execute %q{ ALTER TABLE notifications.alerts RENAME TO event_subscriptions }
  end

  def down
    execute %q{ ALTER TABLE notifications.event_subscriptions RENAME TO alerts }
  end
end
