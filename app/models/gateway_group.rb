# frozen_string_literal: true

# == Schema Information
#
# Table name: gateway_groups
#
#  id                     :integer(4)       not null, primary key
#  max_rerouting_attempts :integer(2)       default(10), not null
#  name                   :string           not null
#  prefer_same_pop        :boolean          default(TRUE), not null
#  balancing_mode_id      :integer(2)       default(1), not null
#  vendor_id              :integer(4)       not null
#
# Indexes
#
#  gateway_groups_name_key       (name) UNIQUE
#  gateway_groups_vendor_id_idx  (vendor_id)
#
# Foreign Keys
#
#  gateway_groups_contractor_id_fkey  (vendor_id => contractors.id)
#

class GatewayGroup < ApplicationRecord
  BALANCING_MODE_PRIO_WEIGHT = 1
  BALANCING_MODE_PRIO_WEIGHT_PREFER_SAME_POP = 2
  BALANCING_MODE_PRIO_WEIGHT_EXCLUDE_OTHER_POP = 3
  BALANCING_MODES = {
    BALANCING_MODE_PRIO_WEIGHT => 'Priority/Weigth balancing',
    BALANCING_MODE_PRIO_WEIGHT_PREFER_SAME_POP => 'Priority/Weigth balancing. Prefer gateways from same POP',
    BALANCING_MODE_PRIO_WEIGHT_EXCLUDE_OTHER_POP => 'Priority/Weigth balancing. Exclude gateways from other POPs'
  }.freeze

  belongs_to :vendor, class_name: 'Contractor'

  has_many :gateways, dependent: :restrict_with_error
  has_many :dialpeers, dependent: :restrict_with_error
  has_many :rate_management_projects, class_name: 'RateManagement::Project'
  has_many :active_rate_management_pricelist_items,
           -> { not_applied },
           class_name: 'RateManagement::PricelistItem'
  has_many :applied_rate_management_pricelist_items,
           -> { applied },
           class_name: 'RateManagement::PricelistItem',
           dependent: :nullify

  include WithPaperTrail

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }
  validates :vendor, presence: true
  validates :max_rerouting_attempts, numericality: { greater_than: 0, less_than_or_equal_to: 30, allow_nil: false, only_integer: true }
  validates :balancing_mode_id, inclusion: { in: BALANCING_MODES.keys }, allow_nil: false

  validate :contractor_is_vendor
  validate :vendor_can_be_changed

  before_destroy :check_associated_records

  scope :search_for, lambda { |term|
    where("gateway_groups.name || ' | ' || gateway_groups.id::varchar ILIKE ?", "%#{term}%")
  }

  def display_name
    "#{name} | #{id}"
  end

  def balancing_mode_name
    BALANCING_MODES[balancing_mode_id]
  end

  def have_valid_gateways?
    gateways.where('enabled and allow_termination').count > 0
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      search_for
    ]
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

  def check_associated_records
    project_ids = rate_management_projects.pluck(:id)
    if project_ids.any?
      errors.add(:base, "Can't be deleted because linked to Rate Management Project(s) ##{project_ids.join(', #')}")
    end

    pricelist_ids = active_rate_management_pricelist_items.pluck(Arel.sql('DISTINCT(pricelist_id)'))
    if pricelist_ids.any?
      errors.add(:base, "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist_ids.join(', #')}")
    end

    throw(:abort) if errors.any?
  end
end
