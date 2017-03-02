module Reporter
  class CustomerTraffic < Base

    def email_columns
      [:vendor,
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

    def email_columns_by_destination
      [
          :destination_prefix,
          :country,
          :network,
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
          [:decorated_asr, 'ASR'],
          [:decorated_acd, 'ACD'],
          [:decorated_origination_cost, 'Origination cost'],
          [:decorated_termination_cost, 'Termination cost'],
          [:decorated_profit, 'Profit'],
          :first_call_at,
          :last_call_at
      ]
    end

    def email_subject
      'Customer traffic report'
    end

    def csv_data
      [
          CsvData.new(report.csv_columns, report.report_records_by_vendor),
          CsvData.new(report.csv_columns_by_destination, report.report_records_by_destination),
          CsvData.new(report.csv_columns_full, report.report_records_full)
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
