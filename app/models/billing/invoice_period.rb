# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_periods
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  invoice_periods_name_key  (name) UNIQUE
#

class Billing::InvoicePeriod < Yeti::ActiveRecord
  DAILY_ID = 1
  WEEKLY_ID = 2
  BIWEEKLY_ID = 3
  MONTHLY_ID = 4
  BIWEEKLY_SPLIT_ID = 5
  WEEKLY_SPLIT_ID = 6

  NAMES = {
    DAILY_ID => 'DAILY',
    WEEKLY_ID => 'WEEKLY',
    BIWEEKLY_ID => 'BIWEEKLY',
    MONTHLY_ID => 'MONTHLY',
    BIWEEKLY_SPLIT_ID => 'BIWEEKLY_SPLIT',
    WEEKLY_SPLIT_ID => 'WEEKLY_SPLIT'
  }.freeze

  SPLIT_PERIOD_IDS = [BIWEEKLY_SPLIT_ID, WEEKLY_SPLIT_ID].freeze

  DAILY_FROM_NOW = -> { today + 1.day }

  DAILY_AGO = ->(end_date) { end_date - 1.day }

  WEEKLY_FROM_NOW = -> { Date.commercial(today.year, today.cweek) + 1.week }

  WEEKLY_AGO = ->(end_date) { Date.commercial(end_date.year, end_date.cweek) - 1.week }

  WEEKLY_SPLIT_FROM_NOW =
    lambda do
      today_week_end = Date.commercial(today.year, today.cweek).end_of_week
      today.month == today_week_end.month ? today_week_end + 1.day : today.end_of_month + 1.day
    end

  WEEKLY_SPLIT_AGO =
    lambda do |end_date|
      end_date_week_start = Date.commercial(end_date.year, end_date.cweek)
      if end_date == end_date_week_start
        prev_week_start = end_date - 1.week
        prev_week_end = prev_week_start.end_of_week
        prev_week_start.month == prev_week_end.month ? prev_week_start : prev_week_start.end_of_month + 1.day
      else
        end_date_week_start
      end
    end

  BIWEEKLY_FROM_NOW =
    lambda do
      today_week_start = Date.commercial(today.year, today.cweek)
      [today_week_start + 2.weeks, today_week_start + 1.week].detect { |d| d.cweek.even? }
    end

  BIWEEKLY_AGO = ->(end_date) { end_date - 2.weeks }

  BIWEEKLY_SPLIT_FROM_NOW =
    lambda do
      today_week_start = Date.commercial(today.year, today.cweek)
      next_biweekly_start = [today_week_start + 2.weeks, today_week_start + 1.week].detect { |d| d.cweek.even? }
      today.month == next_biweekly_start.month ? next_biweekly_start : today.end_of_month + 1.day
    end

  BIWEEKLY_SPLIT_AGO =
    lambda do |end_date|
      end_date_week_start = Date.commercial(end_date.year, end_date.cweek)
      if end_date == end_date_week_start
        prev_biweekly_start = [end_date - 1.week, end_date - 2.weeks].detect { |d| d.cweek.even? }
        prev_biweekly_end = prev_biweekly_start.end_of_week + 1.week
        prev_biweekly_start.month == prev_biweekly_end.month ?
            prev_biweekly_start :
            prev_biweekly_start.end_of_month + 1.day
      else
        [end_date_week_start, end_date_week_start - 1.week].detect { |d| d.cweek.even? }
      end
    end

  MONTHLY_FROM_NOW = -> { today.end_of_month + 1.day }

  MONTHLY_AGO = ->(end_date) { end_date - 1.month }

  DAILY_INC = ->(dt) { dt + 1.day }

  WEEKLY_INC = ->(dt) { dt + 1.week }

  WEEKLY_SPLIT_INC =
    lambda do |dt|
      next_date = dt.end_of_week + 1.second
      dt.month == next_date.month ? next_date : next_date.beginning_of_month
    end

  BIWEEKLY_INC = ->(dt) { dt + 2.weeks }

  BIWEEKLY_SPLIT_INC =
    lambda do |dt|
      next_date = dt.to_time.end_of_week + 1.second # + 1.week
      next_date += 1.week unless next_date.to_date.cweek.even?
      dt.month == next_date.month ? next_date : next_date.beginning_of_month
    end

  MONTHLY_INC = ->(dt) { dt.at_beginning_of_month.next_month }

  def next_date_from_now
    self.class.const_get("#{NAMES[id]}_FROM_NOW").call
  end

  def initial_date(end_date)
    self.class.const_get("#{NAMES[id]}_AGO").call(end_date)
  end

  def next_date(dt)
    self.class.const_get("#{NAMES[id]}_INC").call(dt)
  end

  def invoice_type(date_start, date_end)
    date_start = date_start.to_date
    date_end = date_end.to_date

    return Billing::InvoiceType::AUTO_FULL unless SPLIT_PERIOD_IDS.include?(id)

    if date_start.month != date_end.month && date_end - date_start < days_in_period
      Billing::InvoiceType::AUTO_PARTIAL
    else
      Billing::InvoiceType::AUTO_FULL
    end
  end

  def days_in_period
    case id
    when DAILY_ID then
      1
    when WEEKLY_ID, WEEKLY_SPLIT_ID then
      7
    when BIWEEKLY_ID, BIWEEKLY_SPLIT_ID then
      14
    when MONTHLY_ID then
      30
    end
  end

  def self.today
    Date.today
    # Time.now.to_date
  end
end
