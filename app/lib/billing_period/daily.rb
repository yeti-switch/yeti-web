# frozen_string_literal: true

module BillingPeriod
  class Daily < Base
    self.days_in_period = 1

    def period_end_for(time)
      date = time.to_date
      period_end_date = date + 1.day

      date_to_time_in_time_zone(period_end_date)
    end

    def period_start_for(period_end)
      period_end_date = period_end.to_date
      period_start_date = period_end_date - 1.day

      date_to_time_in_time_zone(period_start_date)
    end
  end
end
