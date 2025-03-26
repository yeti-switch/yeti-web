# frozen_string_literal: true

module Worker
  class CdrExportJob < ::ApplicationJob
    queue_as 'cdr_export'

    def perform(cdr_export_id)
      cdr_export = nil
      Cdr::Base.transaction do
        cdr_export = CdrExport.find(cdr_export_id)

        if cdr_export.time_zone_name.present?
          sanitized_time_zone = Cdr::Base.sanitize_sql(['SET LOCAL timezone TO ?', cdr_export.time_zone_name])
          Cdr::Base.connection.execute(sanitized_time_zone)
        end

        rows_count = Cdr::Cdr.connection.execute("COPY (#{cdr_export.export_sql}) TO PROGRAM 'gzip > #{file_path_for(cdr_export)}' WITH (FORMAT CSV, HEADER, FORCE_QUOTE *);").cmd_tuples

        # update cdr_export status
        cdr_export.update!(
          status: CdrExport::STATUS_COMPLETED,
          rows_count: rows_count
        )
      end
    rescue StandardError => e
      logger.error { e.message }
      logger.error { e.backtrace.join("\n") }
      capture_error(e)
      cdr_export.update!(status: CdrExport::STATUS_FAILED)
    ensure
      # ping callback_url
      if cdr_export.callback_url.present?
        params = { export_id: cdr_export.id, status: cdr_export.status }
        PingCallbackUrlJob.perform_later(cdr_export.callback_url, params)
      end
    end

    private

    def file_path_for(cdr_export)
      "#{dir_path}/#{cdr_export.id}.csv.gz"
    end

    def dir_path
      YetiConfig.cdr_export.dir_path.chomp('/')
    end
  end
end
