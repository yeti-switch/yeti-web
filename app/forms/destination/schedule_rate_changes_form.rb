# frozen_string_literal: true

module Destination
  class ScheduleRateChangesForm < ApplicationForm
    attribute :apply_time, :date
    attribute :initial_interval, :integer
    attribute :initial_rate, :decimal
    attribute :next_interval, :integer
    attribute :next_rate, :decimal
    attribute :connect_fee, :decimal
    attribute :ids_sql, :string

    validates :initial_rate, :next_rate, :connect_fee, numericality: true
    validates :initial_interval, :next_interval, numericality: { greater_than: 0, less_than_or_equal_to: ApplicationRecord::PG_MAX_SMALLINT }
    validates :ids_sql, :apply_time, presence: true
    validate :validate_apply_time

    def self.form_inputs
      {
        apply_time: 'datepicker',
        initial_interval: 'text',
        initial_rate: 'text',
        next_interval: 'text',
        next_rate: 'text',
        connect_fee: 'text'
      }
    end

    private

    def _save
      Worker::ScheduleRateChanges.perform_later(
        ids_sql,
        apply_time:,
        initial_interval:,
        initial_rate:,
        next_interval:,
        next_rate:,
        connect_fee:
      )
    end

    def validate_apply_time
      return if apply_time.nil?

      errors.add(:apply_time, 'must be in the future') unless apply_time.future?
    end
  end
end
