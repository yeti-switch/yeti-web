# frozen_string_literal: true

module Cdr
  class UploadCdrExport < ApplicationService
    parameter :key, required: true
    parameter :source, required: true

    Error = Class.new(StandardError)

    def call
      raise_if_invalid!
      S3AttachmentWrapper.upload!(cdr_export_bucket, key, source)
    rescue Aws::S3::Errors::ServiceError => e
      raise Error, "Failed to upload CDR export: #{e.message}"
    end

    private

    define_memoizable :cdr_export_bucket, apply: lambda {
      YetiConfig.s3_storage&.cdr_export&.bucket
    }

    def raise_if_invalid!
      raise Error, 'CDR export bucket is not configured' unless CdrExport.s3_storage_configured?
    end
  end
end
