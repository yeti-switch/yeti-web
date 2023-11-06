# frozen_string_literal: true

module BillingInvoice
  module CalculatePeriod
    # Calculates period_start, period_end, and type_id for current period.
    class Current < ApplicationService
      # @!method account [Account]
      parameter :account, required: true

      # @raise [ApplicationService::Error]
      # @return [Hash(:start_time, :end_time, :type_id)]
      #  :start_time [Time] invoice.start_date for current invoice period.
      #  :end_time [Time] invoice.end_date for current invoice period.
      #  :type_id [Integer] invoice.type_id for current invoice period.
      def call
        validate!

        last_invoice_end_time = BillingInvoice::CalculatePeriod.last_invoice_end_time(
            time_zone: time_zone,
            account_id: account.id
          )

        end_time = period_class.period_end_for(time_zone, time_zone.now.to_date)
        start_time = last_invoice_end_time || period_class.period_start_for(time_zone, end_time)

        type_id = BillingInvoice::CalculatePeriod.invoice_type_id(
            start_time: start_time,
            end_time: end_time,
            period_class: period_class
          )

        {
          start_time: start_time,
          end_time: end_time,
          type_id: type_id
        }
      end

      private

      # @!method time_zone [ActiveSupport::TimeZone]
      define_memoizable :time_zone, apply: lambda {
        BillingInvoice::CalculatePeriod.time_zone_for(account.timezone.name)
      }

      # @!method period_class [Class<BillingPeriod::Base>]
      define_memoizable :period_class, apply: lambda {
        BillingInvoice::CalculatePeriod.period_class(account_invoice_period_id)
      }

      delegate :invoice_period_id, to: :account, prefix: true

      # @raise [ApplicationService::Error]
      def validate!
        raise Error, 'account is required' if account.nil?
        raise Error, "failed to find time zone #{account.timezone.name}" if time_zone.nil?
        raise Error, 'account invoice period is required' if account_invoice_period_id.nil?
      end
    end
  end
end
