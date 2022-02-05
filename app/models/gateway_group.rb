# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id                :integer(4)       not null, primary key
#  is_shared         :boolean          default(FALSE), not null
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

class GatewayGroup < ApplicationRecord
  belongs_to :vendor, class_name: 'Contractor'
  belongs_to :balancing_mode, class_name: 'Equipment::GatewayGroupBalancingMode', foreign_key: :balancing_mode_id

  has_many :gateways, dependent: :restrict_with_error
  has_many :dialpeers, dependent: :restrict_with_error

  include WithPaperTrail

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }
  validates :vendor, :balancing_mode, presence: true

  validate :contractor_is_vendor
  validate :vendor_can_be_changed
  validate :is_shared_can_be_changed

  scope :for_termination, lambda { |contractor_id|
    where("#{table_name}.vendor_id=? OR #{table_name}.is_shared", contractor_id)
      .joins(:vendor)
      .order(:name)
  }

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

  def is_shared_can_be_changed
    return true unless is_shared_changed?(from: true, to: false)

    if dialpeers.any?
      errors.add(:is_shared, I18n.t('activerecord.errors.models.gateway_group.attributes.is_shared.cant_be_disabled_when_linked_to_dialpeer'))
    end
  end
end
