# frozen_string_literal: true

# == Schema Information
#
# Table name: dns.dns_records
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
    'SRV' => 'SRV',
    'CNAME' => 'CNAME',
    'TXT' => 'TXT'
  }.freeze

  belongs_to :zone, class_name: 'Equipment::Dns::Zone', foreign_key: :zone_id
  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id, optional: true

  validates :name, :record_type, :content, :zone, presence: true
  validates :record_type, inclusion: { in: RECORD_TYPES.keys }, allow_nil: false

  after_save do
    zone.serial_increment
  end

  after_destroy do
    zone.serial_increment
  end

  def display_name
    "#{name} | #{id}"
  end
end
