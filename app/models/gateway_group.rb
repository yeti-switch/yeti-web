# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id                :integer(4)       not null, primary key
#  name              :string           not null
#  prefer_same_pop   :boolean          default(TRUE), not null
#  balancing_mode_id :integer(2)       default(1), not null
#  vendor_id         :integer(4)       not null
#
# Indexes
#
#  gateway_groups_name_key  (name) UNIQUE
#
# Foreign Keys
#
#  gateway_groups_balancing_mode_id_fkey  (balancing_mode_id => gateway_group_balancing_modes.id)
#  gateway_groups_contractor_id_fkey      (vendor_id => contractors.id)
#

class GatewayGroup < ActiveRecord::Base
  belongs_to :vendor, class_name: 'Contractor'
  belongs_to :balancing_mode, class_name: 'Equipment::GatewayGroupBalancingMode', foreign_key: :balancing_mode_id

  has_many :gateways, dependent: :restrict_with_error
  has_many :dialpeers, dependent: :restrict_with_error

  has_paper_trail class_name: 'AuditLogItem'

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }
  validates :vendor, :balancing_mode, presence: true

  validate :contractor_is_vendor
  validate :vendor_can_be_changed

  def display_name
    "#{name} | #{id}"
  end

  def have_valid_gateways?
    gateways.where('enabled and allow_termination').count > 0
  end

  protected

  def contractor_is_vendor
    errors.add(:vendor, 'Is not vendor') unless vendor&.vendor
  end

  def vendor_can_be_changed
    if vendor_id_changed?
      errors.add(:vendor, "can't be changed because Gateway Group contain gateways") if gateways.any?
      errors.add(:vendor, "can't be changed because Gateway Group belongs to dialpeers") if dialpeers.any?
    end
  end
end
