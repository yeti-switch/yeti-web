# frozen_string_literal: true

module Jobs
  class AccountBalanceNotify < ::BaseJob
    self.cron_line = '* * * * *'

    def execute
      AccountBalanceThreshold.accounts_required_notification.find_each do |account|
        capture_job_extra(account_balance_extra(account)) do
          AccountBalanceThreshold.new(account).check_threshold
        end
      end
    end

    private

    def account_balance_extra(account)
      {
        account_id: account.id,
        account_balance: account.balance,
        balance_low_threshold: account.balance_notification_setting&.low_threshold,
        balance_high_threshold: account.balance_notification_setting&.high_threshold,
        state_id: account.balance_notification_setting&.state_id
      }
    end
  end
end
