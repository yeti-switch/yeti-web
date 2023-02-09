# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_groups
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routing_groups_name_unique  (name) UNIQUE
#

class Routing::RoutingGroup < ApplicationRecord
  self.table_name = 'class4.routing_groups'

  before_destroy :sociated_records

  has_and_belongs_to_many :routing_plans, class_name: 'Routing::RoutingPlan',
                                          join_table: 'class4.routing_plan_groups'

  has_many :dialpeers, dependent: :destroy
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

  def display_name
    "#{name} | #{id}"
  end

  def have_routing_plans?
    routing_plans.count > 0
  end

  private

  def sociated_records
    if routing_plans.count > 0
      errors.add(:base, 'Routing Group used in Routing Plan configuration. You must unlink it first')
    end

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
