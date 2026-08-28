# frozen_string_literal: true

# == Schema Information
#
# Table name: dns.dns_records
# Database name: primary
#
#  id            :integer(4)       not null, primary key
#  content       :string           not null
#  name          :string           not null
#  record_type   :string           not null
#  contractor_id :integer(4)
#  zone_id       :integer(2)       not null
#
# Indexes
#
#  dns_records_contractor_id_idx  (contractor_id)
#  dns_records_zone_id_idx        (zone_id)
#
# Foreign Keys
#
#  dns_records_contractor_id_fkey  (contractor_id => contractors.id)
#  dns_records_zone_id_fkey        (zone_id => dns.dns_zones.id)
#
RSpec.describe Equipment::Dns::Record, type: :model do
  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let!(:zone) { FactoryBot.create(:dns_zone) }
    let(:record_type) { 'A' }
    let(:content) { '192.0.2.1' }
    let(:create_params) do
      { zone: zone, name: 'test', record_type: record_type, content: content }
    end

    include_examples :creates_record

    context 'with unknown record_type' do
      let(:record_type) { 'PTR' }

      include_examples :does_not_create_record, errors: {
        record_type: 'is not included in the list'
      }
    end

    {
      'NS' => ['ns1.example.com.', 'ns1.example.com', '@'],
      'A' => ['192.0.2.1'],
      'AAAA' => ['2001:db8::1'],
      'MX' => ['10 mail.example.com.', '0 @', '65535 mail.example.com.', '0 .'],
      'SRV' => ['10 5 5060 sip.example.com.', '0 0 0 .'],
      'CNAME' => ['example.com.', '@'],
      'TXT' => ['v=spf1 -all', 'any text at all']
    }.each do |type, contents|
      contents.each do |valid_content|
        context "with #{type} record and content #{valid_content.inspect}" do
          let(:record_type) { type }
          let(:content) { valid_content }

          include_examples :creates_record
        end
      end
    end

    {
      'NS' => ['record content', 'ns1 example com'],
      'A' => ['192.0.2.1/24', '2001:db8::1', 'not an ip'],
      'AAAA' => ['192.0.2.1', 'not an ip'],
      'MX' => ['mail.example.com.', '10', '65536 mail.example.com.', '-1 mail.example.com.',
               '10 mail.example.com. extra'],
      'SRV' => ['10 5 sip.example.com.', '10 5 70000 sip.example.com.', 'sip.example.com.'],
      'CNAME' => ['not a hostname']
    }.each do |type, contents|
      contents.each do |invalid_content|
        context "with #{type} record and content #{invalid_content.inspect}" do
          let(:record_type) { type }
          let(:content) { invalid_content }

          include_examples :does_not_create_record, errors: {
            content: "is invalid for #{type} record. #{Equipment::Dns::Record::CONTENT_HINTS[type]}"
          }
        end
      end
    end

    {
      'MX' => "10\nmail.example.com.",
      'SRV' => "10 5 5060\nsip.example.com.",
      'TXT' => "first line\nsecond line"
    }.each do |type, multiline_content|
      context "with #{type} record and multiline content" do
        let(:record_type) { type }
        let(:content) { multiline_content }

        include_examples :does_not_create_record, errors: {
          content: 'must not contain line breaks'
        }
      end
    end
  end
end
