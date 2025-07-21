# frozen_string_literal: true

module Worker
  class CdrExportJob < ::ApplicationJob
    queue_as 'cdr_export'

    attr_reader :cdr_export

    def perform(cdr_export_id)
      Cdr::Base.transaction do
        @cdr_export = CdrExport.find(cdr_export_id)

        if cdr_export.time_zone_name.present?
          sanitized_time_zone = Cdr::Base.sanitize_sql(['SET LOCAL timezone TO ?', cdr_export.time_zone_name])
          Cdr::Base.connection.execute(sanitized_time_zone)
        end

        rows_count = if CdrExport.s3_storage_configured?
                       export_to_storage!
                     else
                       export_to_file!
                     end

        # update cdr_export status
        cdr_export.update!(
          status: CdrExport::STATUS_COMPLETED,
          rows_count:
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

    def export_to_storage!
      rows = []
      Cdr::Cdr.connection.execute("COPY (#{cdr_export.export_sql}) TO STDOUT WITH (FORMAT CSV, HEADER, FORCE_QUOTE *);")
      while (row = Cdr::Cdr.connection.raw_connection.get_copy_data)
        rows << row
      end
      compressed_data = Zlib.gzip(rows.join, level: Zlib::BEST_COMPRESSION)
      Cdr::UploadCdrExport.call(key: cdr_export.filename, source: StringIO.new(compressed_data))

      rows.size - 1 # Exclude header row from count
    end

    def export_to_file!
      result = Cdr::Cdr.connection.execute("COPY (#{cdr_export.export_sql}) TO PROGRAM 'gzip > #{file_path}' WITH (FORMAT CSV, HEADER, FORCE_QUOTE *);")
      result.cmd_tuples
    end

    def file_path
      "#{dir_path}/#{cdr_export.filename}"
    end

    def dir_path
      YetiConfig.cdr_export.dir_path.chomp('/')
    end
  end
end
