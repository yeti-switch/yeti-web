# frozen_string_literal: true

module Cdr
  class DownloadCallRecord < ApplicationService
    parameter :cdr, required: true
    parameter :response_object, required: true

    Error = Class.new(StandardError)
    NotFoundError = Class.new(Error)

    def call
      raise_if_invalid!

      if s3_storage_configured?
        download_from_s3
      else
        setup_x_accel_redirect_header
      end
    rescue Aws::S3::Errors::NoSuchKey => e
      raise NotFoundError, "Call Recording file not found: #{e.message}"
    rescue Aws::S3::Errors::ServiceError => e
      raise Error, "Failed to download Call Recording file: #{e.message}"
    end

    private

    def raise_if_invalid!
      raise NotFoundError, 'There is no call recording file found for this CDR' if !cdr.has_recording? || cdr.call_record_file_name.nil?
    end

    define_memoizable :call_record_bucket, apply: lambda {
      YetiConfig.s3_storage&.call_record&.bucket
    }

    def s3_storage_configured?
      call_record_bucket.present?
    end

    def setup_x_accel_redirect_header
      response_object.headers['X-Accel-Redirect'] = cdr.call_record_file_path
      response_object.headers['Content-Type'] = cdr.call_record_ct
    end

    def download_from_s3
      response_object.headers['Content-Disposition'] = "attachment; filename=\"#{cdr.call_record_file_name}\""
      response_object.headers['Content-Type'] = 'application/octet-stream'

      S3AttachmentWrapper.stream_to!(call_record_bucket, cdr.call_record_file_path) do |chunk|
        response_object.stream.write(chunk)
      end
    end
  end
end
