# frozen_string_literal: true

module Jobs
  class ServiceRenew < ::BaseJob
    self.cron_line = '* * * * *'

    def execute
      Billing::Service.for_renew.each(&:renew)
    end
  end
end
