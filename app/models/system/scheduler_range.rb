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

  # we are redefining types there to not process time as ruby Time type - it causing a lot of problems with time zones
  # so we are just passing it to/from DB as is.
  # drawback - it requires custom validation
  attribute :from_time, :string
  attribute :till_time, :string

  belongs_to :scheduler, class_name: 'System::Scheduler', foreign_key: :scheduler_id

  validates :from_time, format: { with: /\A([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?\z/ }, allow_nil: true, allow_blank: true
  validates :till_time, format: { with: /\A([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?\z/ }, allow_nil: true, allow_blank: true

  before_validation :replace_blank_time_with_nil

  # somehow it works even when time is interpreted as text
  validates :from_time, comparison: { less_than: :till_time }, if: -> { till_time.present? }, allow_nil: true, allow_blank: true
  validates :till_time, comparison: { greater_than: :from_time }, if: -> { from_time.present? }, allow_nil: true, allow_blank: true

  validates :weekdays, inclusion: { in: WEEKDAYS.keys }, allow_nil: false, presence: true

  scope :current_ranges, lambda { |tz|
    where('date_part(\'dow\', (now() at time zone ?)) = ANY(weekdays)', tz)
      .where('(from_time IS NOT NULL AND (now() at time zone ?)::time >= from_time)', tz)
      .where('(till_time IS NOT NULL AND (now() at time zone ?)::time < till_time)', tz)
  }

  def weekdays=(s)
    # form sends empty array element, we have to remove it
    self[:weekdays] = s.uniq.sort.reject(&:blank?)
  end

  def weekdays_names
    weekdays.collect { |w| WEEKDAYS[w] }.join(', ')
  end

  protected

  def replace_blank_time_with_nil
    self.from_time = nil if from_time.blank?
    self.till_time = nil if till_time.blank?
  end
end
