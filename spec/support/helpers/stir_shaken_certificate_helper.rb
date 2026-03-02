# frozen_string_literal: true

require 'openssl'

module StirShakenCertificateHelper
  module_function

  # Builds a valid X509 certificate PEM and private key PEM.
  # @param tn_auth_entries [Array<Hash>] TNAuthList entries to include in the certificate.
  #   Each entry is a hash with :type and type-specific keys:
  #     { type: :spc, value: '1234' }
  #     { type: :tn, value: '12155551234' }
  #     { type: :range, start: '12155550000', count: 100 }
  # @return [Array(String, String)] certificate PEM and private key PEM
  def build_cert_pem(tn_auth_entries: [])
    ca_key = OpenSSL::PKey::RSA.new(1024)
    ca_cert = build_ca_cert(ca_key)

    cert_key = OpenSSL::PKey::RSA.new(1024)
    cert = build_leaf_cert(cert_key:, ca_cert:, ca_key:, tn_auth_entries:)

    [cert.to_pem, cert_key.to_pem]
  end

  # Builds a concatenated PEM containing leaf certificate + CA certificate (chain).
  # @param tn_auth_entries [Array<Hash>] TNAuthList entries for the leaf certificate.
  # @return [Array(String, String)] certificate chain PEM and leaf private key PEM
  def build_cert_chain_pem(tn_auth_entries: [])
    ca_key = OpenSSL::PKey::RSA.new(1024)
    ca_cert = build_ca_cert(ca_key)

    cert_key = OpenSSL::PKey::RSA.new(1024)
    cert = build_leaf_cert(cert_key:, ca_cert:, ca_key:, tn_auth_entries:)

    chain_pem = cert.to_pem + ca_cert.to_pem
    [chain_pem, cert_key.to_pem]
  end

  def build_ca_cert(ca_key)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.parse('/CN=Test CA')
    cert.issuer = cert.subject
    cert.public_key = ca_key.public_key
    cert.not_before = Time.utc(2024, 1, 1)
    cert.not_after = Time.utc(2034, 1, 1)
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))
    cert.add_extension(ef.create_extension('authorityKeyIdentifier', 'keyid:always'))
    cert.sign(ca_key, OpenSSL::Digest::SHA256.new)
    cert
  end

  def build_leaf_cert(cert_key:, ca_cert:, ca_key:, tn_auth_entries: [])
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 2
    cert.subject = OpenSSL::X509::Name.parse('/CN=Test SHAKEN')
    cert.issuer = ca_cert.subject
    cert.public_key = cert_key.public_key
    cert.not_before = Time.utc(2024, 1, 1)
    cert.not_after = Time.utc(2034, 1, 1)
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = ca_cert
    cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))
    cert.add_extension(ef.create_extension('authorityKeyIdentifier', 'keyid:always'))
    cert.add_extension(build_tn_auth_list_extension(tn_auth_entries)) if tn_auth_entries.present?
    cert.sign(ca_key, OpenSSL::Digest::SHA256.new)
    cert
  end

  # Builds TNAuthList extension with IMPLICIT tagging per RFC 8226.
  # Real SHAKEN certificates use implicit tagging where primitive values (IA5String)
  # are encoded directly with context-specific tags, not wrapped in constructed tags.
  def build_tn_auth_list_extension(entries)
    tn_entries = entries.map do |entry|
      case entry[:type]
      when :spc
        # [0] IMPLICIT IA5String - primitive context-specific tag
        OpenSSL::ASN1::ASN1Data.new(entry[:value], 0, :CONTEXT_SPECIFIC)
      when :range
        start_tn = OpenSSL::ASN1::IA5String.new(entry[:start])
        count = OpenSSL::ASN1::Integer.new(entry[:count])
        seq = OpenSSL::ASN1::Sequence.new([start_tn, count])
        # [1] IMPLICIT SEQUENCE - constructed context-specific tag
        OpenSSL::ASN1::ASN1Data.new([seq], 1, :CONTEXT_SPECIFIC)
      when :tn
        # [2] IMPLICIT IA5String - primitive context-specific tag
        OpenSSL::ASN1::ASN1Data.new(entry[:value], 2, :CONTEXT_SPECIFIC)
      end
    end
    tn_auth_list = OpenSSL::ASN1::Sequence.new(tn_entries)
    OpenSSL::X509::Extension.new(
      '1.3.6.1.5.5.7.1.26',
      OpenSSL::ASN1::OctetString.new(tn_auth_list.to_der)
    )
  end
end
