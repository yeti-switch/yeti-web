# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.scheduler_ranges
#
#  id           :integer(2)       not null, primary key
#  from_time    :time
#  till_time    :time
#  weekdays     :integer(2)       default([]), not null, is an Array
#  scheduler_id :integer(2)       not null
#
# Indexes
#
#  scheduler_ranges_scheduler_id_idx  (scheduler_id)
#
# Foreign Keys
#
#  scheduler_ranges_scheduler_id_fkey  (scheduler_id => schedulers.id)
#
class System::SchedulerRange < ApplicationRecord
  self.table_name = 'sys.scheduler_ranges'

  WEEKDAY_SUNDAY = 0
  WEEKDAY_MONDAY = 1
  WEEKDAY_TUESDAY = 2
  WEEKDAY_WEDNESDAY = 3
  WEEKDAY_THURSDAY = 4
  WEEKDAY_FRIDAY = 5
  WEEKDAY_SATURDAY = 6

  WEEKDAYS = {
    WEEKDAY_SUNDAY => 'Sunday',
    WEEKDAY_MONDAY => 'Monday',
    WEEKDAY_TUESDAY => 'Tuesday',
    WEEKDAY_WEDNESDAY => 'Wednesday',
    WEEKDAY_THURSDAY => 'Thursday',
    WEEKDAY_FRIDAY => 'Friday',
    WEEKDAY_SATURDAY => 'Saturday'
  }.freeze

  belongs_to :scheduler, class_name: 'System::Scheduler', foreign_key: :scheduler_id

  validates :till_time, comparison: { greater_than: :from_time }
  validates :from_time, comparison: { less_than: :till_time }
  validates :weekdays, inclusion: { in: WEEKDAYS.keys }, allow_nil: false, presence: true

  scope :current_ranges, lambda {
    t = Time.current
    where('? = ANY(weekdays)', t.wday)
      .where('(from_time IS NOT NULL AND ? >= from_time)', t.strftime('%T'))
      .where('(till_time IS NOT NULL AND ? < till_time)', t.strftime('%T'))
  }

  def weekdays=(s)
    # form sending empty array element, we have to remove it
    self[:weekdays] = s.uniq.sort.reject(&:blank?)
  end

  def weekdays_names
    weekdays.collect { |w| WEEKDAYS[w] }.join(', ')
  end
end
