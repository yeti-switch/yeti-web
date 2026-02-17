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
