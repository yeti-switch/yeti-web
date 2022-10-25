class EventSubscriptionsAddUrl < ActiveRecord::Migration[6.1]
  def change
    add_column 'notifications.event_subscriptions', :url, :string
  end
end
