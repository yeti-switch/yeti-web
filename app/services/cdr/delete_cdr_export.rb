# frozen_string_literal: true

module Cdr
  class DeleteCdrExport < ApplicationService
    parameter :cdr_export, required: true

    SUCCESS_HTTP_CODES = [200, 204].freeze

    Error = Class.new(StandardError)
    NotFoundError = Class.new(Error)
    class FileNotDeletedError < Error
      def initialize(http_code)
        @http_code = http_code
      end

      def message
        "File was not deleted! http code: #{@http_code}"
      end
    end

    def call
      if CdrExport.s3_storage_configured?
        delete_from_s3_storage
      else
        remove_file_from_self_storage
      end
    end

    private

    define_memoizable :cdr_export_bucket, apply: lambda {
      YetiConfig.s3_storage&.cdr_export&.bucket
    }

    def delete_from_s3_storage
      S3AttachmentWrapper.delete!(cdr_export_bucket, cdr_export.filename)
    rescue Aws::S3::Errors::NoSuchKey => e
      raise NotFoundError, "Cdr Export file not found: #{e.message}"
    rescue Aws::S3::Errors::ServiceError => e
      raise Error, "Failed to delete Cdr Export file: #{e.message}"
    end

    def remove_file_from_self_storage
      url = URI.parse(delete_url)
      req = Net::HTTP::Delete.new(url.to_s)
      res = Net::HTTP.start(
        url.host,
        url.port,
        use_ssl: url.scheme == 'https',
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        http.request(req)
      end
      http_code = res.code.to_i

      return if SUCCESS_HTTP_CODES.include?(http_code)
      raise NotFoundError, 'Cdr Export file not found' if http_code == 404

      raise FileNotDeletedError, http_code
    end

    def delete_url
      [
        YetiConfig.cdr_export.delete_url.chomp('/'),
        cdr_export.filename
      ].join('/')
    end
  end
end
