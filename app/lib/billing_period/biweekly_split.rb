# frozen_string_literal: true

module BillingPeriod
  class BiweeklySplit < Base
    split_period
    self.days_in_period = 14

    def period_end_for(time)
      date = time.to_date
      today_week_start = Date.commercial(date.year, date.cweek)
      next_biweekly_start = [
        today_week_start + 2.weeks, today_week_start + 1.week
      ].detect { |d| d.cweek.even? }

      if date.month == next_biweekly_start.month
        period_end_date = next_biweekly_start
      else
        period_end_date = date.end_of_month + 1.day
      end

      date_to_time_in_time_zone(period_end_date)
    end

    def period_start_for(period_end)
      period_end_date = period_end.to_date
      period_end_week_start = Date.commercial(period_end_date.year, period_end_date.cweek)

      if period_end_date == period_end_week_start
        prev_biweekly_start = [
          period_end_date - 1.week,
          period_end_date - 2.weeks
        ].detect { |d| d.cweek.even? }
        prev_biweekly_end = prev_biweekly_start.end_of_week + 1.week

        period_start_date = prev_biweekly_start.month == prev_biweekly_end.month ?
                              prev_biweekly_start :
                              prev_biweekly_start.end_of_month + 1.day
      else
        period_start_date = [
          period_end_week_start,
          period_end_week_start - 1.week
        ].detect { |d| d.cweek.even? }
      end

      date_to_time_in_time_zone(period_start_date)
    end
  end
end
