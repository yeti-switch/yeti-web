# frozen_string_literal: true

module Worker
  class CdrExportJob < ActiveJob::Base
    queue_as 'cdr_export'

    def perform(cdr_export_id)
      cdr_export = CdrExport.find(cdr_export_id)

      rows_count = Cdr::Cdr.connection.execute("COPY (#{cdr_export.export_sql}) TO '#{file_path_for(cdr_export)}' WITH (FORMAT CSV, HEADER, FORCE_QUOTE *);").cmd_tuples

      # update cdr_export status
      cdr_export.update!(
        status: CdrExport::STATUS_COMPLETED,
        rows_count: rows_count
      )
    rescue StandardError => e
      logger.error { e.message }
      logger.error { e.backtrace.join("\n") }
      cdr_export.update!(status: CdrExport::STATUS_FAILED)
    ensure
      # ping callback_url
      if cdr_export.callback_url
        params = { export_id: cdr_export.id, status: cdr_export.status }
        PingCallbackUrlJob.perform_later(cdr_export.callback_url, params)
      end
    end

    private

    def file_path_for(cdr_export)
      "#{dir_path}/#{cdr_export.id}.csv"
    end

    def dir_path
      Rails.configuration.yeti_web.fetch('cdr_export').fetch('dir_path').chomp('/')
    end
  end
end
