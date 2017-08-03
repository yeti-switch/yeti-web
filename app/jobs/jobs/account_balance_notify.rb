module Jobs
  class AccountBalanceNotify < ::BaseJob

    def execute
      notifications.each do |ev|
#        begin
          Log::BalanceNotification.transaction do
            ev.process!
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

