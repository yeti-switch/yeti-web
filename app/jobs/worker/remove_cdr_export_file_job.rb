# frozen_string_literal: true

require 'net/http'

module Worker
  class RemoveCdrExportFileJob < ActiveJob::Base
    class FileNotDeletedError < RuntimeError
      def initialize(http_code)
        @http_code = http_code
      end

      def message
        "File was not deleted! http code: #{@http_code}"
      end
    end

    queue_as 'cdr_export'
    ALLOWED_HTTP_CODES = [200, 204, 404].freeze

    def perform(cdr_export_id)
      url = URI.parse(delete_url(cdr_export_id))
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
      unless ALLOWED_HTTP_CODES.include?(http_code)
        raise FileNotDeletedError, http_code
      end
    end

    private

    def delete_url(cdr_export_id)
      [
        Rails.configuration.yeti_web.fetch('cdr_export').fetch('delete_url').chomp('/'),
        "#{cdr_export_id}.csv"
      ].join('/')
    end
  end
end
