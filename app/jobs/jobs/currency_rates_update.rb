# frozen_string_literal: true

module Jobs
  class CurrencyRatesUpdate < ::BaseJob
    # ECB-based providers publish new rates once per working day,
    # hourly run picks them up soon after publication.
    self.cron_line = '25 * * * *'

    def execute
      CurrencyRates::Update.call
    end
  end
end
