# frozen_string_literal: true

module Jobs
  class AccountBalanceNotify < ::BaseJob
    def execute
      notifications.each do |ev|
        #        begin
        Log::BalanceNotification.transaction do
          capture_job_extra(id: ev.id) do
            ev.process!
          end
        end
      end
      notifications.count
    end

    protected

    def notifications
      @notifications ||= Log::BalanceNotification.order('created_at').where('not is_processed')
    end
  end
end
