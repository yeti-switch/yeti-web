# frozen_string_literal: true

module BillingPeriod
  class Biweekly < Base
    self.days_in_period = 14

    def period_end_for(time)
      date = time.to_date
      today_week_start = Date.commercial(date.cwyear, date.cweek)

      period_end_date = [
        today_week_start + 2.weeks,
        today_week_start + 1.week
      ].detect { |d| d.cweek.even? }

      date_to_time_in_time_zone(period_end_date)
    end

    def period_start_for(period_end)
      period_end_date = period_end.to_date
      period_start_date = Date.commercial(period_end_date.cwyear, period_end_date.cweek) - 2.weeks

      date_to_time_in_time_zone(period_start_date)
    end
  end
end
