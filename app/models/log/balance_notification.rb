# frozen_string_literal: true

# == Schema Information
#
# Table name: balance_notifications
#
#  id           :bigint(8)        not null, primary key
#  created_at   :datetime         not null
#  is_processed :boolean          default(FALSE), not null
#  processed_at :datetime
#  direction    :string
#  action       :string
#  data         :json
#

class Log::BalanceNotification < ApplicationRecord
  self.table_name = 'balance_notifications'
  scope :processed, -> { where('is_processed') }
  scope :not_processed, -> { where('not is_processed') }

  def display_name
    id.to_s
  end

  def process!
    acc = Account.find(data['id'].to_i)

    if direction == 'low' && action == 'fire'
      NotificationEvent.low_threshold_reached(acc, data)

    elsif direction == 'low' && action == 'clear'
      NotificationEvent.low_threshold_cleared(acc, data)

    elsif direction == 'high' && action == 'fire'
      NotificationEvent.high_threshold_reached(acc, data)

    elsif direction == 'high' && action == 'clear'
      NotificationEvent.high_threshold_cleared(acc, data)

    end

    self.is_processed = true
    self.processed_at = Time.now # seems it will write wrong time when timezone is not UTC
    save!
  end
end
