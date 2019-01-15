# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_periods
#
#  id   :integer          not null, primary key
#  name :string           not null
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
  DAILY_AGO = -> { today - 1.day }

  WEEKLY_FROM_NOW = lambda {
    Date.commercial(today.year, today.cweek) + 1.week
  }

  WEEKLY_AGO = lambda {
    WEEKLY_FROM_NOW.call - 1.week
  }

  WEEKLY_SPLIT_FROM_NOW = lambda {
    last_date = WEEKLY_SPLIT_AGO.call.to_time
    next_date = last_date.end_of_week + 1.second
    last_date.month == next_date.month ? next_date : next_date.beginning_of_month
  }

  WEEKLY_SPLIT_AGO = lambda {
    last_date = Date.commercial(today.year, today.cweek)
    last_date.month == today.month ? last_date : today.beginning_of_month
  }

  BIWEEKLY_FROM_NOW = lambda {
    [Date.commercial(today.year, today.cweek) + 2.week,
     Date.commercial(today.year, today.cweek) + 1.week]
      .select { |d| d.cweek.even? }.first
  }

  BIWEEKLY_AGO = lambda {
    BIWEEKLY_FROM_NOW.call - 2.weeks
  }

  BIWEEKLY_SPLIT_FROM_NOW = lambda {
    last_date = BIWEEKLY_SPLIT_AGO.call.to_time
    next_date = last_date.end_of_week + 1.second
    next_date += 1.week unless next_date.to_date.cweek.even?
    last_date.month == next_date.month ? next_date : next_date.beginning_of_month
  }

  BIWEEKLY_SPLIT_AGO = lambda {
    last_date = [
      Date.commercial(today.year, today.cweek),
      Date.commercial(today.year, today.cweek) - 1.week

    ].select { |d| d.cweek.even? }.first
    last_date.month == today.month ? last_date : today.beginning_of_month
  }

  MONTHLY_FROM_NOW = lambda {
    # Time.now.months_since(1).beginning_of_month
    today.at_beginning_of_month.next_month
  }

  MONTHLY_AGO = lambda {
    MONTHLY_FROM_NOW.call.prev_month
  }

  DAILY_INC = ->(dt) { dt + 1.day }

  WEEKLY_INC = ->(dt) { dt + 1.week }

  WEEKLY_SPLIT_INC = lambda { |dt|
    next_date = dt.end_of_week + 1.second
    dt.month == next_date.month ? next_date : next_date.beginning_of_month
  }

  BIWEEKLY_INC = ->(dt) { dt + 2.weeks }

  BIWEEKLY_SPLIT_INC = lambda { |dt|
    next_date = dt.to_time.end_of_week + 1.second # + 1.week
    next_date += 1.week unless next_date.to_date.cweek.even?
    dt.month == next_date.month ? next_date : next_date.beginning_of_month
  }

  MONTHLY_INC = lambda { |dt|
    dt.at_beginning_of_month.next_month
  }

  def next_date_from_now
    self.class.const_get("#{NAMES[id]}_FROM_NOW").call
  end

  def initial_date
    self.class.const_get("#{NAMES[id]}_AGO").call
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
    when DAILY_ID then 1
    when WEEKLY_ID, WEEKLY_SPLIT_ID then 7
    when BIWEEKLY_ID, BIWEEKLY_SPLIT_ID then 14
    when MONTHLY_ID then 30
    end
  end

  def self.today
    Date.today
    # Time.now.to_date
  end
end
