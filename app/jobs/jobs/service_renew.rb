module Jobs
  class ServiceRenew < ::BaseJob
    self.cron_line = '* * * * *'

    def execute
      Billing::Service.for_renew.each do |svc|
        svc.renew
      end
    end

  end
end