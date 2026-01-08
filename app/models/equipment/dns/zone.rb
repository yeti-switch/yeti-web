# frozen_string_literal: true

# == Schema Information
#
# Table name: dns.dns_zones
#
#  id        :integer(2)       not null, primary key
#  expire    :integer(2)       default(1800), not null
#  minimum   :integer(2)       default(3600), not null
#  name      :string           not null
#  refresh   :integer(2)       default(600), not null
#  retry     :integer(2)       default(600), not null
#  serial    :bigint(8)        default(0), not null
#  soa_mname :string           not null
#  soa_rname :string           not null
#
# Indexes
#
#  dns_zones_name_key  (name) UNIQUE
#
class Equipment::Dns::Zone < ApplicationRecord
  self.table_name = 'dns.dns_zones'

  include WithPaperTrail

  MAX_SERIAL = 4_294_967_295
  MAX_EXPIRE = 2_147_483_647

  has_many :records, class_name: 'Equipment::Dns::Record', foreign_key: :zone_id, dependent: :destroy

  validates :name, :soa_mname, :soa_rname, :serial, :refresh, :retry, :expire, :minimum, presence: true

  validates :serial, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: MAX_SERIAL,
    allow_nil: false
  }

  validates :expire, :refresh, :retry, :minimum, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: MAX_EXPIRE,
    allow_nil: false
  }

  def display_name
    "#{name} | #{id}"
  end

  def serial_increment
    if serial == MAX_SERIAL
      self.serial = 0
    else
      self.serial += 1
    end

    save!
  end
end
