# frozen_string_literal: true

require 'openssl'
require 'time'

module Equipment
  module StirShaken
    module CertificateDetails
      CERTIFICATE_PEM_PATTERN = /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m

      def certificate_details
        pem_blocks = extract_certificate_pem_blocks
        return '' if pem_blocks.empty?

        pem_blocks.each_with_index.map do |pem, index|
          format_certificate_details_block(pem:, index:, total: pem_blocks.size)
        end.join("\n\n")
      end

      private

      def extract_certificate_pem_blocks
        raw_certificate = certificate.to_s
        return [] if raw_certificate.blank?

        pem_blocks = raw_certificate.scan(CERTIFICATE_PEM_PATTERN)
        pem_blocks.presence || [raw_certificate]
      end

      def format_certificate_details_block(pem:, index:, total:)
        certificate = OpenSSL::X509::Certificate.new(pem)
        lines = []
        lines << "Certificate ##{index + 1}" if total > 1
        lines << "Subject: #{x509_name(certificate.subject)}"
        lines << "Issuer: #{x509_name(certificate.issuer)}"
        lines << "Not Before: #{certificate.not_before.utc.iso8601}"
        lines << "Not After: #{certificate.not_after.utc.iso8601}"
        lines << "X509v3 Subject Key Identifier: #{format_key_identifier(certificate.subject_key_identifier)}"
        lines << "X509v3 Authority Key Identifier: #{format_key_identifier(certificate.authority_key_identifier)}"
        lines.join("\n")
      rescue OpenSSL::X509::CertificateError, OpenSSL::ASN1::ASN1Error => e
        error_lines = []
        error_lines << "Certificate ##{index + 1}" if total > 1
        error_lines << "Unable to decode certificate: #{e.message}"
        error_lines.join("\n")
      end

      def x509_name(name)
        name.to_s(OpenSSL::X509::Name::RFC2253)
      end

      def format_key_identifier(key_identifier)
        return 'N/A' if key_identifier.blank?

        key_identifier.unpack1('H*').upcase.scan(/../).join(':')
      end
    end
  end
end
