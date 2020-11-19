# frozen_string_literal: true

module BillingPeriod
  class WeeklySplit < Base
    split_period
    self.days_in_period = 7

    def period_end_for(time)
      date = time.to_date
      today_week_end = Date.commercial(date.year, date.cweek).end_of_week
      if date.month == today_week_end.month
        period_end_date = today_week_end + 1.day
      else
        period_end_date = date.end_of_month + 1.day
      end

      date_to_time_in_time_zone(period_end_date)
    end

    def period_start_for(period_end)
      period_end_date = period_end.to_date
      week_start = Date.commercial(period_end_date.year, period_end_date.cweek)

      if period_end_date == week_start
        prev_week_start = period_end_date - 1.week
        prev_week_end = prev_week_start.end_of_week
        period_start_date = prev_week_start.month == prev_week_end.month ?
                              prev_week_start :
                              prev_week_start.end_of_month + 1.day
      else
        period_start_date = week_start
      end

      date_to_time_in_time_zone(period_start_date)
    end
  end
end
