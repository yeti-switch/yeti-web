# frozen_string_literal: true

module Jobs
  class DeleteBalanceNotifications < ::BaseJob
    self.cron_line = '0 0 * * *'

    def execute
      return if delete_date.nil?

      scoped_collection.delete_all
    end

    private

    def scoped_collection
      Log::BalanceNotification.where('created_at <= ?', delete_date)
    end

    def delete_date
      return @delete_date if instance_variable_defined?(:@delete_date)

      keep_days = YetiConfig.keep_balance_notifications_days
      @delete_date = keep_days.present? ? keep_days.days.ago : nil
    end
  end
end
