# frozen_string_literal: true

module BillingInvoice
  module CalculatePeriod
    PERIOD_CLASS_NAMES = {
      Billing::InvoicePeriod::DAILY => 'BillingPeriod::Daily',
      Billing::InvoicePeriod::WEEKLY => 'BillingPeriod::Weekly',
      Billing::InvoicePeriod::BIWEEKLY => 'BillingPeriod::Biweekly',
      Billing::InvoicePeriod::MONTHLY => 'BillingPeriod::Monthly',
      Billing::InvoicePeriod::BIWEEKLY_SPLIT => 'BillingPeriod::BiweeklySplit',
      Billing::InvoicePeriod::WEEKLY_SPLIT => 'BillingPeriod::WeeklySplit'
    }.freeze

    module_function

    # @param invoice_period_id [Integer] ID of Billing::InvoicePeriod.
    # @return [Class<BillingPeriod::Base>]
    def period_class(invoice_period_id)
      PERIOD_CLASS_NAMES.fetch(invoice_period_id).constantize
    end

    # @param name [String] name of time zone.
    # @return [ActiveSupport::TimeZone]
    def time_zone_for(name)
      ActiveSupport::TimeZone.new(name)
    end

    # @param time_zone [ActiveSupport::TimeZone]
    # @param account_id [Integer]
    # @return [Time]
    def last_invoice_end_time(time_zone:, account_id:)
      scope = Billing::Invoice.where(account_id: account_id).order('end_date desc').limit(1)
      invoice = scope.take
      return if invoice.nil?

      invoice.end_date.in_time_zone(time_zone)
    end

    # @param start_time [Time]
    # @param end_time [Time]
    # @param period_class [Class<BillingPeriod::Base>]
    # @return [Integer] ID of Billing::InvoiceType.
    def invoice_type_id(start_time:, end_time:, period_class:)
      days_in_invoice = end_time.to_date.mjd - start_time.to_date.mjd

      if period_class.split_period? && days_in_invoice < period_class.days_in_period
        Billing::InvoiceType::AUTO_PARTIAL
      else
        Billing::InvoiceType::AUTO_FULL
      end
    end
  end
end
