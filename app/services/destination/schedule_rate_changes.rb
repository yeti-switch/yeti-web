# frozen_string_literal: true

module Destination
  class ScheduleRateChanges < ApplicationService
    parameter :ids, required: true
    parameter :apply_time, required: true
    parameter :initial_interval, required: true
    parameter :initial_rate, required: true
    parameter :next_interval, required: true
    parameter :next_rate, required: true
    parameter :connect_fee, required: true

    VALID_TILL = 40.years.freeze
    Error = Class.new(StandardError)

    def call
      raise_if_invalid!

      ApplicationRecord.transaction do
        Routing::Destination.where('id IN (?) AND valid_till <= ?', ids, apply_time).update_all(valid_till: apply_time + VALID_TILL)
        Routing::DestinationNextRate.where(destination_id: ids).delete_all

        next_rate_attrs = ids.map do |destination_id|
          {
            initial_interval:,
            initial_rate:,
            next_interval:,
            next_rate:,
            connect_fee:,
            apply_time:,
            destination_id:
          }
        end

        Routing::DestinationNextRate.insert_all!(next_rate_attrs)
      end
    end

    private

    def raise_if_invalid!
      raise Error, "Ids can't be blank" if ids.blank?
      raise Error, 'Apply time must be in the future' unless apply_time.future?
    end
  end
end
