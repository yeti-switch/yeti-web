# frozen_string_literal: true

require 'net/http'

module Worker
  class RemoveCdrExportFileJob < ::ApplicationJob
    queue_as 'cdr_export'

    def perform(cdr_export_id)
      cdr_export = CdrExport.find(cdr_export_id)
      Cdr::DeleteCdrExport.call(cdr_export:)
    rescue Cdr::DeleteCdrExport::NotFoundError => e
      Rails.logger.warn("Cdr Export ##{cdr_export.id} file not found during deletion: #{e.message}")
    end
  end
end
