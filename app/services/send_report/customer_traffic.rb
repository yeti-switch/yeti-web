# frozen_string_literal: true

module SendReport
  class CustomerTraffic < Base
    private

    def email_columns
      [:vendor,
       :calls_count,
       :success_calls_count,
       :short_calls_count,
       [:decorated_calls_duration, 'Calls duration'],
       [:decorated_customer_calls_duration, 'Customer calls duration'],
       [:decorated_vendor_calls_duration, 'Vendor calls duration'],
       [:decorated_asr, 'ASR'],
       [:decorated_acd, 'ACD'],
       [:decorated_origination_cost, 'Origination cost'],
       [:decorated_termination_cost, 'Termination cost'],
       [:decorated_profit, 'Profit'],
       :first_call_at,
       :last_call_at]
    end

    def email_columns_by_destination
      [
        :destination_prefix,
        :country,
        :network,
        :calls_count,
        :success_calls_count,
        :short_calls_count,
        [:decorated_calls_duration, 'Calls duration'],
        [:decorated_customer_calls_duration, 'Customer calls duration'],
        [:decorated_vendor_calls_duration, 'Vendor calls duration'],
        [:decorated_asr, 'ASR'],
        [:decorated_acd, 'ACD'],
        [:decorated_origination_cost, 'Origination cost'],
        [:decorated_termination_cost, 'Termination cost'],
        [:decorated_profit, 'Profit'],
        :first_call_at,
        :last_call_at
      ]
    end

    def email_columns_full
      [
        :vendor,
        :destination_prefix,
        :country,
        :network,
        :calls_count,
        :success_calls_count,
        :short_calls_count,
        [:decorated_calls_duration, 'Calls duration'],
        [:decorated_customer_calls_duration, 'Customer calls duration'],
        [:decorated_vendor_calls_duration, 'Vendor calls duration'],
        [:decorated_asr, 'ASR'],
        [:decorated_acd, 'ACD'],
        [:decorated_origination_cost, 'Origination cost'],
        [:decorated_termination_cost, 'Termination cost'],
        [:decorated_profit, 'Profit'],
        :first_call_at,
        :last_call_at
      ]
    end

    def csv_columns
      %i[vendor
         calls_count
         success_calls_count
         short_calls_count
         calls_duration
         customer_calls_duration
         vendor_calls_duration
         acd
         asr
         origination_cost
         termination_cost
         profit
         first_call_at
         last_call_at]
    end

    def csv_columns_by_destination
      %i[
        destination_prefix
        country
        network
        calls_count
        success_calls_count
        short_calls_count
        calls_duration
        customer_calls_duration
        vendor_calls_duration
        acd
        asr
        origination_cost
        termination_cost
        profit
        first_call_at
        last_call_at
      ]
    end

    def csv_columns_full
      %i[
        vendor
        destination_prefix
        country
        network
        calls_count
        success_calls_count
        short_calls_count
        calls_duration
        customer_calls_duration
        vendor_calls_duration
        acd
        asr
        origination_cost
        termination_cost
        profit
        first_call_at
        last_call_at
      ]
    end

    def email_subject
      'Customer traffic report'
    end

    def csv_data
      [
        CsvData.new(csv_columns, report.report_records_by_vendor),
        CsvData.new(csv_columns_by_destination, report.report_records_by_destination),
        CsvData.new(csv_columns_full, report.report_records_full)
      ]
    end

    def email_data
      [
        EmailData.new(email_columns, report.report_records_by_vendor, ReportCustomerTrafficByVendorDecorator),
        EmailData.new(email_columns_by_destination, report.report_records_by_destination, ReportCustomerTrafficByDestinationDecorator),
        EmailData.new(email_columns_full, report.report_records_full, ReportCustomerTrafficFullDecorator)
      ]
    end
  end
end
