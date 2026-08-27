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
class Equipment::Dns::Record < ApplicationRecord
  self.table_name = 'dns.dns_records'

  include WithPaperTrail

  RECORD_TYPES = {
    'NS' => 'NS',
    'A' => 'A',
    'AAAA' => 'AAAA',
    'MX' => 'MX',
    'SRV' => 'SRV',
    'CNAME' => 'CNAME',
    'TXT' => 'TXT'
  }.freeze

  CONTENT_HINTS = {
    'NS' => 'Name server hostname. Example: ns1.example.com.',
    'A' => 'IPv4 address. Example: 192.0.2.1',
    'AAAA' => 'IPv6 address. Example: 2001:db8::1',
    'MX' => 'Priority(0..65535) and mail server hostname, separated by space. Example: 10 mail.example.com.',
    'SRV' => 'Priority, weight, port(0..65535 each) and target hostname, separated by spaces. ' \
             'Example: 10 5 5060 sip.example.com.',
    'CNAME' => 'Canonical hostname. Example: example.com. or @',
    'TXT' => 'Arbitrary text. Example: v=spf1 -all'
  }.freeze

  UINT16_RANGE = (0..65_535)
  HOSTNAME_LABEL = '[a-zA-Z0-9_](?:[a-zA-Z0-9_-]*[a-zA-Z0-9_])?'
  HOSTNAME_REGEXP = /\A#{HOSTNAME_LABEL}(?:\.#{HOSTNAME_LABEL})*\.?\z/

  belongs_to :zone, class_name: 'Equipment::Dns::Zone', foreign_key: :zone_id
  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id, optional: true

  validates :name, :record_type, :content, :zone, presence: true
  validates :record_type, inclusion: { in: RECORD_TYPES.keys }, allow_nil: false
  validate :validate_content_format

  after_save do
    zone.serial_increment
  end

  after_destroy do
    zone.serial_increment
  end

  def self.content_hint(record_type)
    CONTENT_HINTS[record_type]
  end

  def display_name
    "#{name} | #{id}"
  end

  private

  def validate_content_format
    return if content.blank? || !RECORD_TYPES.key?(record_type)
    return if content_format_valid?

    errors.add(:content, "is invalid for #{record_type} record. #{CONTENT_HINTS[record_type]}")
  end

  def content_format_valid?
    case record_type
    when 'A' then ip_address_content?(:ipv4?)
    when 'AAAA' then ip_address_content?(:ipv6?)
    when 'NS', 'CNAME' then hostname?(content)
    when 'MX' then mx_content?
    when 'SRV' then srv_content?
    else true # TXT content is arbitrary
    end
  end

  def ip_address_content?(kind)
    return false if content.include?('/') # netmask is not a valid record content

    IPAddr.new(content).public_send(kind)
  rescue IPAddr::Error
    false
  end

  def mx_content?
    priority, target, *rest = content.split
    rest.empty? && uint16?(priority) && hostname?(target)
  end

  def srv_content?
    priority, weight, port, target, *rest = content.split
    rest.empty? &&
      [priority, weight, port].all? { |value| uint16?(value) } &&
      (target == '.' || hostname?(target))
  end

  def uint16?(value)
    value.to_s.match?(/\A\d{1,5}\z/) && UINT16_RANGE.cover?(value.to_i)
  end

  def hostname?(value)
    value == '@' || value.to_s.match?(HOSTNAME_REGEXP)
  end
end
