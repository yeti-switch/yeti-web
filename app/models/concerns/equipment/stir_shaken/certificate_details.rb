# frozen_string_literal: true

require 'openssl'
require 'time'

module Equipment
  module StirShaken
    module CertificateDetails
      CERTIFICATE_PEM_PATTERN = /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m
      TN_AUTH_LIST_OID = '1.3.6.1.5.5.7.1.26'

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
        lines.concat(format_tn_auth_list(certificate))
        lines.join("\n")
      rescue OpenSSL::X509::CertificateError, OpenSSL::ASN1::ASN1Error => e
        error_lines = []
        error_lines << "Certificate ##{index + 1}" if total > 1
        error_lines << "Unable to decode certificate: #{e.message}"
        error_lines.join("\n")
      end

      def format_tn_auth_list(certificate)
        ext = certificate.extensions.find { |e| e.oid == TN_AUTH_LIST_OID }
        return [] if ext.nil?

        tn_auth_seq = decode_tn_auth_list(ext)
        entries = tn_auth_seq.value.map { |entry| format_tn_auth_entry(entry) }
        ['TNAuthList:'] + entries.map { |e| "  #{e}" }
      rescue OpenSSL::ASN1::ASN1Error
        ['TNAuthList: unable to decode']
      end

      def decode_tn_auth_list(ext)
        decoded = OpenSSL::ASN1.decode(ext.value_der)
        # value_der may or may not include OCTET STRING wrapper depending on
        # how the extension was encoded. If first decode returns an OctetString,
        # we need a second decode to get the actual TNAuthList sequence.
        decoded.tag == OpenSSL::ASN1::OCTET_STRING ? OpenSSL::ASN1.decode(decoded.value) : decoded
      end

      def format_tn_auth_entry(entry)
        case entry.tag
        when 0
          "SPC: #{asn1_entry_value(entry)}"
        when 1
          seq = entry.value.is_a?(Array) ? entry.value.first : OpenSSL::ASN1.decode(entry.value)
          "TN Range: #{seq.value[0].value}, count: #{seq.value[1].value}"
        when 2
          "TN: #{asn1_entry_value(entry)}"
        else
          "Unknown entry tag: #{entry.tag}"
        end
      end

      # Extracts string value from ASN1 entry handling both implicit and explicit tagging.
      # Implicit tagging (real certificates per RFC 8226): entry.value is a String.
      # Explicit tagging: entry.value is an Array containing an ASN1 object.
      def asn1_entry_value(entry)
        entry.value.is_a?(String) ? entry.value : entry.value.first.value
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
