# frozen_string_literal: true

module BillingPeriod
  class Weekly < Base
    self.days_in_period = 7

    def period_end_for(time)
      date = time.to_date
      period_end_date = Date.commercial(date.cwyear, date.cweek) + 1.week

      date_to_time_in_time_zone(period_end_date)
    end

    def period_start_for(period_end)
      period_end_date = period_end.to_date
      period_start_date = Date.commercial(period_end_date.cwyear, period_end_date.cweek) - 1.week

      date_to_time_in_time_zone(period_start_date)
    end
  end
end
