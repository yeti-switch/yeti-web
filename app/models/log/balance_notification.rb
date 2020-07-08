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

class Log::BalanceNotification < ActiveRecord::Base
  self.table_name = 'balance_notifications'
  scope :processed, -> { where('is_processed') }
  scope :not_processed, -> { where('not is_processed') }

  def display_name
    id.to_s
  end

  def process!
    acc = Account.find(data['id'].to_i)

    if direction == 'low' && action == 'fire'
      acc.fire_low_balance_alarm(data)

    elsif direction == 'low' && action == 'clear'
      acc.clear_low_balance_alarm(data)

    elsif direction == 'high' && action == 'fire'
      acc.fire_high_balance_alarm(data)

    elsif direction == 'high' && action == 'clear'
      acc.clear_high_balance_alarm(data)

    end

    self.is_processed = true
    self.processed_at = Time.now # seems it will write wrong time when timezone is not UTC
    save!
  end
end
