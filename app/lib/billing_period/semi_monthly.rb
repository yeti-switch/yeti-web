# frozen_string_literal: true

module BillingPeriod
  class SemiMonthly < Base
    # Period length varies between 13 and 16 days, so this value is nominal.
    # It is only used for AUTO_PARTIAL detection of split periods, which this period is not.
    self.days_in_period = 15

    def period_end_for(time)
      date = time.to_date
      period_end_date = date.day < 16 ? date.change(day: 16) : date.end_of_month + 1.day

      date_to_time_in_time_zone(period_end_date)
    end

    def period_start_for(period_end)
      period_end_date = period_end.to_date
      period_start_date = if period_end_date.day == 16
                            period_end_date.change(day: 1)
                          else
                            (period_end_date - 1.day).change(day: 16)
                          end

      date_to_time_in_time_zone(period_start_date)
    end
  end
end
