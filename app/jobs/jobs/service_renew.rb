# frozen_string_literal: true

module Jobs
  class ServiceRenew < ::BaseJob
    self.cron_line = '0 * * * *'

    def execute
      Billing::Service.ready_for_renew.find_each do |service|
        renew(service)
      end
    end

    def renew(service)
      Billing::Service::Renew.perform(service)
    rescue StandardError => e
      log_error(e)
      capture_error(e, extra: { service_id: service.id })
    end
  end
end
