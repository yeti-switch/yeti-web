# frozen_string_literal: true

module Cdr
  class DownloadPcap < ApplicationService
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
      raise NotFoundError, "PCAP file not found: #{e.message}"
    rescue Aws::S3::Errors::ServiceError => e
      raise Error, "Failed to download PCAP file: #{e.message}"
    end

    private

    def raise_if_invalid!
      raise NotFoundError, 'There is no dump file found for this CDR' if !cdr.has_dump? || cdr.dump_file_name.nil?
    end

    define_memoizable :pcap_bucket, apply: lambda {
      YetiConfig.s3_storage&.pcap&.bucket
    }

    def s3_storage_configured?
      pcap_bucket.present?
    end

    def setup_x_accel_redirect_header
      response_object.headers['X-Accel-Redirect'] = cdr.dump_file_path
    end

    def download_from_s3
      response_object.headers['Content-Disposition'] = "attachment; filename=\"#{cdr.dump_file_name}\""
      response_object.headers['Content-Type'] = 'application/octet-stream'

      S3AttachmentWrapper.stream_to!(pcap_bucket, cdr.dump_file_s3_path) do |chunk|
        response_object.stream.write(chunk)
      end
    end
  end
end
