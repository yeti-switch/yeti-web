# frozen_string_literal: true

module SendReport
  class VendorTraffic < Base
    private

    def email_subject
      'Vendor traffic report'
    end

    def csv_columns
      %i[customer
         calls_count
         calls_duration
         customer_calls_duration
         vendor_calls_duration
         acd
         asr
         origination_cost
         termination_cost
         profit
         success_calls_count
         first_call_at
         last_call_at
         short_calls_count]
    end

    def email_columns
      [
        :customer,
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

    def csv_data
      [
        CsvData.new(csv_columns, report.report_records)
      ]
    end

    def email_data
      [
        EmailData.new(email_columns, report.report_records, ReportVendorTrafficDataDecorator)
      ]
    end
  end
end
