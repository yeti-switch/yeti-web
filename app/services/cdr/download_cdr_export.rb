# frozen_string_literal: true

module Cdr
  class DownloadCdrExport < ApplicationService
    parameter :cdr_export, required: true
    parameter :response_object, required: true
    parameter :public, default: false

    Error = Class.new(StandardError)
    NotFoundError = Class.new(Error)

    def call
      if CdrExport.s3_storage_configured?
        download_from_s3
      else
        setup_x_accel_redirect_header
      end
    rescue Aws::S3::Errors::NoSuchKey => e
      raise NotFoundError, "Cdr Export file not found: #{e.message}"
    rescue Aws::S3::Errors::ServiceError => e
      raise Error, "Failed to download Cdr Export file: #{e.message}"
    end

    private

    define_memoizable :cdr_export_bucket, apply: lambda {
      YetiConfig.s3_storage&.cdr_export&.bucket
    }

    def setup_x_accel_redirect_header
      response_object.headers['X-Accel-Redirect'] = "/x-redirect/cdr_export/#{cdr_export.filename}"
      response_object.headers['Content-Type'] = 'text/csv; charset=utf-8'
      response_object.headers['Content-Disposition'] = "attachment; filename=\"#{filename_for_response}\""
    end

    def download_from_s3
      response_object.headers['Content-Disposition'] = "attachment; filename=\"#{filename_for_response}\""

      S3AttachmentWrapper.stream_to!(cdr_export_bucket, cdr_export.filename) do |chunk|
        response_object.stream.write(chunk)
      end
    end

    define_memoizable :filename_for_response, apply: lambda {
      public ? cdr_export.public_filename : cdr_export.filename
    }
  end
end
