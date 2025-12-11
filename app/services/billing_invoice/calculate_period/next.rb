# frozen_string_literal: true

module BillingInvoice
  module CalculatePeriod
    # Calculates current period_start, next period_end, and next type_id by current period_end.
    class Next < ApplicationService
      # @!method account [Account]
      parameter :account, required: true
      # @!method period_end [Time]
      parameter :period_end, required: true

      # @raise [ApplicationService::Error]
      # @return [Hash(:start_time, :next_end_time, :next_type_id)]
      #  :start_time [Time] invoice.start_date (period_start) for provided period_end.
      #  :next_end_time [Time] invoice.end_date for next invoice period.
      #  :next_type_id [Integer] invoice.type_id for next invoice period.
      def call
        validate!

        end_time = period_end.in_time_zone(time_zone)
        start_time = period_class.period_start_for(time_zone, end_time)

        next_start_time = end_time
        next_end_time = period_class.period_end_for(time_zone, next_start_time)

        next_type_id = BillingInvoice::CalculatePeriod.invoice_type_id(
            start_time: next_start_time,
            end_time: next_end_time,
            period_class: period_class
          )

        {
          start_time: start_time,
          next_end_time: next_end_time,
          next_type_id: next_type_id
        }
      end

      private

      # @raise [ApplicationService::Error]
      def validate!
        raise Error, 'account is required' if account.nil?
        raise Error, "failed to find time zone #{account.timezone}" if time_zone.nil?
        raise Error, 'account invoice period is required' if account_invoice_period_id.nil?
      end

      # @!method time_zone [ActiveSupport::TimeZone]
      define_memoizable :time_zone, apply: lambda {
        BillingInvoice::CalculatePeriod.time_zone_for(account.timezone)
      }

      # @!method period_class [Class<BillingPeriod::Base>]
      define_memoizable :period_class, apply: lambda {
        BillingInvoice::CalculatePeriod.period_class(account_invoice_period_id)
      }

      delegate :invoice_period_id, to: :account, prefix: true
    end
  end
end
