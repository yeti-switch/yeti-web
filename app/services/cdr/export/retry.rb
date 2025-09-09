# frozen_string_literal: true

module Cdr
  module Export
    class Retry < ApplicationService
      parameter :cdr_export, required: true

      Error = Class.new(StandardError)

      def call
        cdr_export.transaction do
          raise_if_invalid!
          cdr_export.update!(status: CdrExport::STATUS_PENDING)
          Worker::CdrExportJob.perform_later(cdr_export.id)
        end
      end

      private

      def raise_if_invalid!
        raise Error, 'Only failed exports can be retried' unless cdr_export.failed?
      end
    end
  end
end
