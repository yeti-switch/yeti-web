# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id              :integer          not null, primary key
#  vendor_id       :integer          not null
#  name            :string           not null
#  prefer_same_pop :boolean          default(TRUE), not null
#

class GatewayGroup < ActiveRecord::Base
  belongs_to :vendor, class_name: 'Contractor'
  has_many :gateways, dependent: :restrict_with_error
  has_many :dialpeers, dependent: :restrict_with_error

  has_paper_trail class_name: 'AuditLogItem'

  validates_presence_of :name
  validates_uniqueness_of :name, allow_blank: false
  validates_presence_of :vendor

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
