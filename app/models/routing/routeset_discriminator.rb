# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routeset_discriminators
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routeset_discriminators_name_key  (name) UNIQUE
#

class Routing::RoutesetDiscriminator < ApplicationRecord
  self.table_name = 'class4.routeset_discriminators'

  has_many :dialpeers, class_name: 'Dialpeer', foreign_key: :routeset_discriminator_id, dependent: :restrict_with_error

  has_many :rate_management_projects, class_name: 'RateManagement::Project'
  has_many :active_rate_management_pricelist_items,
           -> { not_applied },
           class_name: 'RateManagement::PricelistItem'
  has_many :applied_rate_management_pricelist_items,
           -> { applied },
           class_name: 'RateManagement::PricelistItem',
           dependent: :nullify

  before_destroy :check_associated_records

  include WithPaperTrail

  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: false }

  def display_name
    "#{name} | #{id}"
  end

  private

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
