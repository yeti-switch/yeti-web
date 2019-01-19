# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.scheduler_periods
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Report::SchedulerPeriod < Cdr::Base
  self.table_name = 'reports.scheduler_periods'

  # PeriodData=Struct.new(:next_run_at, :date_from, :date_to)

  class PeriodData < Struct.new(:next_run_at, :date_from, :date_to)
  end

  def time_data(time_now)
    case id
    when 1 # hourly
      data = PeriodData.new(
        time_now.beginning_of_hour + 1.hour + 15.minutes,
        time_now.beginning_of_hour - 1.hour,
        time_now.beginning_of_hour
      )
    when 2 # daily
      data = PeriodData.new(
        time_now.beginning_of_day + 1.day + 30.minutes,
        time_now.beginning_of_day - 1.day,
        time_now.beginning_of_day
      )
    when 3 # weekly
      data = PeriodData.new(
        time_now.beginning_of_week + 1.week + 1.hour,
        time_now.beginning_of_week - 1.week,
        time_now.beginning_of_week
      )
    when 4 # biweekly
      data = PeriodData.new(
        time_now.beginning_of_week + 2.week + 2.hour,
        time_now.beginning_of_week - 2.week,
        time_now.beginning_of_week
      )
    when 5 # monthly
      data = PeriodData.new(
        time_now.beginning_of_month + 1.month + 3.hour,
        time_now.beginning_of_month - 1.month,
        time_now.beginning_of_month
      )
    end
    data
  end
end
