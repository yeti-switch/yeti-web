# frozen_string_literal: true

module Destination
  class ScheduleRateChanges < ApplicationService
    parameter :ids, required: true
    parameter :apply_time, required: true
    parameter :initial_interval
    parameter :initial_rate
    parameter :next_interval
    parameter :next_rate
    parameter :connect_fee

    VALID_TILL = 40.years.freeze
    Error = Class.new(StandardError)

    def call
      raise_if_invalid!

      ApplicationRecord.transaction do
        Routing::Destination.where('id IN (?) AND valid_till <= ?', ids, apply_time).update_all(valid_till: apply_time + VALID_TILL)
        Routing::DestinationNextRate.where(destination_id: ids).delete_all

        sql = <<-SQL.squish
          INSERT INTO class4.destination_next_rates (destination_id, initial_interval, initial_rate, next_interval, next_rate, connect_fee, apply_time, created_at, updated_at)
          SELECT id,
                 #{initial_interval.nil? ? 'initial_interval' : ':initial_interval'},
                 #{initial_rate.nil? ? 'initial_rate' : ':initial_rate'},
                 #{next_interval.nil? ? 'next_interval' : ':next_interval'},
                 #{next_rate.nil? ? 'next_rate' : ':next_rate'},
                 #{connect_fee.nil? ? 'connect_fee' : ':connect_fee'},
                 :apply_time,
                 NOW(),
                 NOW()
          FROM class4.destinations
          WHERE id IN (#{ids.join(',')})
        SQL
        sanitized_sql = SqlCaller::Yeti.sanitize_sql_array(sql,
                                                           initial_interval:,
                                                           initial_rate:,
                                                           next_interval:,
                                                           next_rate:,
                                                           connect_fee:,
                                                           apply_time:)
        SqlCaller::Yeti.execute(sanitized_sql)
      end
    end

    private

    def raise_if_invalid!
      raise Error, "Ids can't be blank" if ids.blank?
      raise Error, "Apply time can't be blank" if apply_time.blank?
      raise Error, 'Apply time must be in the future' unless apply_time.future?
      if initial_interval.nil? && initial_rate.nil? && next_interval.nil? && next_rate.nil? && connect_fee.nil?
        raise Error, 'At least one of the following parameters must be present: initial_interval, initial_rate, next_interval, next_rate, connect_fee'
      end
    end
  end
end
