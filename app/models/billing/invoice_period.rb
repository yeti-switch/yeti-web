# frozen_string_literal: true

class Billing::InvoicePeriod < ApplicationEnum
  DAILY = 1
  WEEKLY = 2
  BIWEEKLY = 3
  MONTHLY = 4
  BIWEEKLY_SPLIT = 5
  WEEKLY_SPLIT = 6

  setup_collection do
    [
      { id: DAILY, name: 'Daily' },
      { id: WEEKLY, name: 'Weekly' },
      { id: BIWEEKLY, name: 'BiWeekly' },
      { id: MONTHLY, name: 'Monthly' },
      { id: BIWEEKLY_SPLIT, name: 'BiWeekly. Split by new month' },
      { id: WEEKLY_SPLIT, name: 'Weekly. Split by new month' }
    ]
  end

  def self.find_by_name(name)
    name = name.to_s
    all.detect { |r| r.name == name }
  end

  attribute :name
end
