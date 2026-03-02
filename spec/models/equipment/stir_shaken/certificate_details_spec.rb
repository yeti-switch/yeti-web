# frozen_string_literal: true

require 'openssl'
require 'time'

RSpec.describe 'STIR/SHAKEN certificate details' do
  let(:issuer_key) { OpenSSL::PKey::RSA.new(1024) }
  let(:subject_key) { OpenSSL::PKey::RSA.new(1024) }
  let(:issuer_certificate) do
    build_certificate(
      common_name: 'Issuer Certificate',
      public_key: issuer_key.public_key,
      signer_key: issuer_key,
      serial: 1
    )
  end
  let(:subject_certificate) do
    build_certificate(
      common_name: 'Subject Certificate',
      public_key: subject_key.public_key,
      signer_key: issuer_key,
      issuer_certificate: issuer_certificate,
      serial: 2
    )
  end

  def build_certificate(common_name:, public_key:, signer_key:, serial:, issuer_certificate: nil)
    certificate = OpenSSL::X509::Certificate.new
    certificate.version = 2
    certificate.serial = serial
    certificate.subject = OpenSSL::X509::Name.parse("/CN=#{common_name}")
    certificate.issuer = (issuer_certificate || certificate).subject
    certificate.public_key = public_key
    certificate.not_before = Time.utc(2024, 1, 1)
    certificate.not_after = Time.utc(2034, 1, 1)

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = certificate
    extension_factory.issuer_certificate = issuer_certificate || certificate

    certificate.add_extension(extension_factory.create_extension('basicConstraints', 'CA:TRUE', true))
    certificate.add_extension(extension_factory.create_extension('subjectKeyIdentifier', 'hash'))
    certificate.add_extension(extension_factory.create_extension('authorityKeyIdentifier', 'keyid:always'))
    certificate.sign(signer_key, OpenSSL::Digest::SHA256.new)
    certificate
  end

  def build_tn_auth_list_extension(entries)
    tn_entries = entries.map do |entry|
      case entry[:type]
      when :spc
        inner = OpenSSL::ASN1::IA5String.new(entry[:value])
        OpenSSL::ASN1::ASN1Data.new([inner], 0, :CONTEXT_SPECIFIC)
      when :range
        start_tn = OpenSSL::ASN1::IA5String.new(entry[:start])
        count = OpenSSL::ASN1::Integer.new(entry[:count])
        seq = OpenSSL::ASN1::Sequence.new([start_tn, count])
        OpenSSL::ASN1::ASN1Data.new([seq], 1, :CONTEXT_SPECIFIC)
      when :tn
        inner = OpenSSL::ASN1::IA5String.new(entry[:value])
        OpenSSL::ASN1::ASN1Data.new([inner], 2, :CONTEXT_SPECIFIC)
      end
    end
    tn_auth_list = OpenSSL::ASN1::Sequence.new(tn_entries)
    OpenSSL::X509::Extension.new(
      '1.3.6.1.5.5.7.1.26',
      OpenSSL::ASN1::OctetString.new(tn_auth_list.to_der)
    )
  end

  def build_certificate_with_tn_auth_list(tn_auth_entries:, signer_key:, issuer_certificate: nil)
    key = OpenSSL::PKey::RSA.new(1024)
    cert = build_certificate(
      common_name: 'SHAKEN Certificate',
      public_key: key.public_key,
      signer_key: signer_key,
      issuer_certificate: issuer_certificate,
      serial: 10
    )
    # Re-add TNAuthList and re-sign (extensions are added before signing)
    unsigned = OpenSSL::X509::Certificate.new(cert.to_der)
    unsigned.add_extension(build_tn_auth_list_extension(tn_auth_entries))
    unsigned.sign(signer_key, OpenSSL::Digest::SHA256.new)
    unsigned
  end

  shared_examples 'certificate_details' do
    let(:record) { described_class.new(base_attributes.merge(attributes)) }
    let(:base_attributes) { { name: 'test' } }
    let(:attributes) { {} }

    it 'displays decoded details for single certificate' do
      record.certificate = subject_certificate.to_pem
      details = record.certificate_details
      expect(details).to include('Subject: CN=Subject Certificate')
      expect(details).to include('Issuer: CN=Issuer Certificate')
      expect(details).to include("Not Before: #{subject_certificate.not_before.utc.iso8601}")
      expect(details).to include("Not After: #{subject_certificate.not_after.utc.iso8601}")
      expect(details).to match(/X509v3 Subject Key Identifier: [0-9A-F]{2}(:[0-9A-F]{2})+/)
      expect(details).to match(/X509v3 Authority Key Identifier: [0-9A-F]{2}(:[0-9A-F]{2})+/)
    end

    it 'displays decoded details for all certificates in certificate chain' do
      certificate_chain = [subject_certificate.to_pem, issuer_certificate.to_pem].join("\n")
      record.certificate = certificate_chain
      details = record.certificate_details

      expect(details).to include('Certificate #1')
      expect(details).to include('Certificate #2')
      expect(details).to include('Subject: CN=Subject Certificate')
      expect(details).to include('Subject: CN=Issuer Certificate')
    end

    it 'returns an error message for invalid certificate' do
      record.certificate = 'invalid-certificate'
      details = record.certificate_details

      expect(details).to include('Unable to decode certificate:')
    end

    it 'displays TNAuthList with SPC entry' do
      cert = build_certificate_with_tn_auth_list(
        tn_auth_entries: [{ type: :spc, value: '1234' }],
        signer_key: issuer_key,
        issuer_certificate: issuer_certificate
      )
      record.certificate = cert.to_pem
      details = record.certificate_details
      expect(details).to include('TNAuthList:')
      expect(details).to include('SPC: 1234')
    end

    it 'displays TNAuthList with individual TN entry' do
      cert = build_certificate_with_tn_auth_list(
        tn_auth_entries: [{ type: :tn, value: '12155551234' }],
        signer_key: issuer_key,
        issuer_certificate: issuer_certificate
      )
      record.certificate = cert.to_pem
      details = record.certificate_details
      expect(details).to include('TNAuthList:')
      expect(details).to include('TN: 12155551234')
    end

    it 'displays TNAuthList with range entry' do
      cert = build_certificate_with_tn_auth_list(
        tn_auth_entries: [{ type: :range, start: '12155550000', count: 100 }],
        signer_key: issuer_key,
        issuer_certificate: issuer_certificate
      )
      record.certificate = cert.to_pem
      details = record.certificate_details
      expect(details).to include('TNAuthList:')
      expect(details).to include('TN Range: 12155550000, count: 100')
    end

    it 'displays TNAuthList with multiple entries' do
      cert = build_certificate_with_tn_auth_list(
        tn_auth_entries: [
          { type: :spc, value: '5678' },
          { type: :tn, value: '12155551234' },
          { type: :range, start: '12155550000', count: 50 }
        ],
        signer_key: issuer_key,
        issuer_certificate: issuer_certificate
      )
      record.certificate = cert.to_pem
      details = record.certificate_details
      expect(details).to include('SPC: 5678')
      expect(details).to include('TN: 12155551234')
      expect(details).to include('TN Range: 12155550000, count: 50')
    end

    it 'does not display TNAuthList when extension is absent' do
      record.certificate = subject_certificate.to_pem
      details = record.certificate_details
      expect(details).not_to include('TNAuthList')
    end
  end

  describe Equipment::StirShaken::TrustedCertificate do
    it_behaves_like 'certificate_details'
  end

  describe Equipment::StirShaken::SigningCertificate do
    let(:base_attributes) do
      {
        name: 'test',
        key: 'test-key',
        x5u: 'https://example.com'
      }
    end

    it_behaves_like 'certificate_details'
  end
end
