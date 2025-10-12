# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.scheduler_ranges
#
#  id           :integer(2)       not null, primary key
#  days         :integer(2)       default([]), not null, is an Array
#  from_time    :time
#  months       :integer(2)       default([]), not null, is an Array
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

  include WithPaperTrail

  WEEKDAYS = {
    0 => 'Sunday',
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday'
  }.freeze

  MONTHS = {
    1 => 'January',
    2 => 'February',
    3 => 'March',
    4 => 'April',
    5 => 'May',
    6 => 'June',
    7 => 'July',
    8 => 'August',
    9 => 'September',
    10 => 'October',
    11 => 'November',
    12 => 'December'
  }.freeze

  DAYS = (1..31).to_a.freeze

  # we are redefining types there to not process time as ruby Time type - it causing a lot of problems with time zones
  # so we are just passing it to/from DB as is.
  # drawback - it requires custom validation
  attribute :from_time, :string
  attribute :till_time, :string

  before_validation :replace_blank_time_with_nil

  belongs_to :scheduler, class_name: 'System::Scheduler', foreign_key: :scheduler_id

  validates :from_time, format: { with: /\A([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?\z/ }, allow_nil: true, allow_blank: true
  validates :till_time, format: { with: /\A([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?\z/ }, allow_nil: true, allow_blank: true
  validates :from_time, comparison: { less_than: :till_time }, if: -> { till_time.present? }, allow_nil: true, allow_blank: true
  validates :till_time, comparison: { greater_than: :from_time }, if: -> { from_time.present? }, allow_nil: true, allow_blank: true

  validates :months, inclusion: { in: MONTHS.keys }, allow_nil: true, presence: false
  validates :days, inclusion: { in: DAYS }, allow_nil: true, presence: false
  validates :weekdays, inclusion: { in: WEEKDAYS.keys }, allow_nil: true, presence: false

  scope :current_ranges, lambda { |tz|
    where('(cardinality(months) = 0 OR date_part(\'month\', (now() at time zone ?)) = ANY(months))', tz)
      .where('(cardinality(days) = 0 OR date_part(\'day\', (now() at time zone ?)) = ANY(days))', tz)
      .where('(cardinality(weekdays) = 0 OR date_part(\'dow\', (now() at time zone ?)) = ANY(weekdays))', tz)
      .where('(from_time IS NULL OR (now() at time zone ?)::time >= from_time)', tz)
      .where('(till_time IS NULL OR (now() at time zone ?)::time < till_time)', tz)
  }

  def months=(s)
    # form sends empty array element, we have to remove it
    self[:months] = s.uniq.sort.reject(&:blank?)
  end

  def days=(s)
    # form sends empty array element, we have to remove it
    self[:days] = s.uniq.sort.reject(&:blank?)
  end

  def weekdays=(s)
    # form sends empty array element, we have to remove it
    self[:weekdays] = s.uniq.sort.reject(&:blank?)
  end

  def months_names
    if months.empty?
      return 'Any'
    end

    months.collect { |w| MONTHS[w] }.join(', ')
  end

  def days_names
    if days.empty?
      return 'Any'
    end

    days.join(', ')
  end

  def weekdays_names
    if weekdays.empty?
      return 'Any'
    end

    weekdays.collect { |w| WEEKDAYS[w] }.join(', ')
  end

  protected

  def replace_blank_time_with_nil
    self.from_time = nil if from_time.blank?
    self.till_time = nil if till_time.blank?
  end
end
