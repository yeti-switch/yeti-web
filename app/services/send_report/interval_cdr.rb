# frozen_string_literal: true

module SendReport
  class IntervalCdr < Base
    private

    def csv_data
      [
        CsvData.new(report.csv_columns, report.report_records)
      ]
    end

    def email_data
      [
        EmailData.new(email_columns, report.report_records)
      ]
    end

    def email_columns
      report.csv_columns.map { |column_name, attribute_name| [attribute_name || column_name, column_name] }
    end

    def email_subject
      'Interval CDR report'
    end
  end
end
