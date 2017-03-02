module Reporter
  class VendorTraffic < Base

    def email_subject
      'Vendor traffic report'
    end

    def email_columns
      [
          :customer,
          :calls_count,
          :success_calls_count,
          :short_calls_count,
          [:decorated_calls_duration, 'Calls duration'],
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
          CsvData.new(report.csv_columns, report.report_records)
      ]
    end

    def email_data
      [
          EmailData.new(email_columns, report.report_records, ReportVendorTrafficDataDecorator)
      ]
    end

  end
end
