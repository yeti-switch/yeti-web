# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_plans
#
#  id                          :integer(4)       not null, primary key
#  max_rerouting_attempts      :integer(2)       default(10), not null
#  name                        :string           not null
#  rate_delta_max              :decimal(, )      default(0.0), not null
#  use_lnp                     :boolean          default(FALSE), not null
#  validate_dst_number_format  :boolean          default(FALSE), not null
#  validate_dst_number_network :boolean          default(FALSE), not null
#  validate_src_number_format  :boolean          default(FALSE), not null
#  validate_src_number_network :boolean          default(FALSE), not null
#  dst_numberlist_id           :integer(2)
#  external_id                 :bigint(8)
#  sorting_id                  :integer(4)       default(1), not null
#  src_numberlist_id           :integer(2)
#
# Indexes
#
#  routing_plans_dst_numberlist_id_idx  (dst_numberlist_id)
#  routing_plans_external_id_key        (external_id) UNIQUE
#  routing_plans_name_key               (name) UNIQUE
#  routing_plans_src_numberlist_id_idx  (src_numberlist_id)
#
# Foreign Keys
#
#  routing_plans_dst_numberlist_id_fkey  (dst_numberlist_id => numberlists.id)
#  routing_plans_src_numberlist_id_fkey  (src_numberlist_id => numberlists.id)
#

class Routing::RoutingPlan < ApplicationRecord
  self.table_name = 'class4.routing_plans'

  SORTING_LCR_PRIO_CONTROL = 1
  SORTING_LCR_NOCONTROL = 2
  SORTING_PRIO_LCR_CONTROL = 3
  SORTING_LCRD_PRIO_CONTROL = 4
  SORTING_TESTING = 5
  SORTING_STATIC_LCR_CONTROL = 6
  SORTING_STATIC_ONLY_NOCONTROL = 7
  SORTINGS = {
    SORTING_LCR_PRIO_CONTROL => 'LCR,Prio, ACD&ASR control',
    SORTING_LCR_NOCONTROL => 'LCR, No ACD&ASR control',
    SORTING_PRIO_LCR_CONTROL => 'Prio,LCR, ACD&ASR control',
    SORTING_LCRD_PRIO_CONTROL => 'LCRD, Prio, ACD&ASR control',
    SORTING_TESTING => 'Route testing',
    SORTING_STATIC_LCR_CONTROL => 'QD-Static, LCR, ACD&ASR control',
    SORTING_STATIC_ONLY_NOCONTROL => 'Static only, No ACD&ASR control'
  }.freeze
  SORTINGS_WITH_STATIC_ROUTES = [SORTING_STATIC_LCR_CONTROL, SORTING_STATIC_ONLY_NOCONTROL].freeze

  belongs_to :dst_numberlist, class_name: 'Routing::Numberlist', foreign_key: :dst_numberlist_id, optional: true
  belongs_to :src_numberlist, class_name: 'Routing::Numberlist', foreign_key: :src_numberlist_id, optional: true

  has_and_belongs_to_many :routing_groups, join_table: 'class4.routing_plan_groups', class_name: 'Routing::RoutingGroup'
  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: :routing_plan_id, dependent: :restrict_with_error
  has_many :static_routes, class_name: 'Routing::RoutingPlanStaticRoute',
                           foreign_key: :routing_plan_id, dependent: :delete_all

  has_many :lnp_rules, class_name: 'Lnp::RoutingPlanLnpRule', foreign_key: :routing_plan_id, dependent: :delete_all

  include WithPaperTrail

  validates :name, :max_rerouting_attempts, presence: true
  validates :name, uniqueness: { allow_blank: false }
  validates :max_rerouting_attempts, numericality: { greater_than: 0, less_than_or_equal_to: 30, allow_nil: false, only_integer: true }
  validates :external_id, uniqueness: { allow_blank: true }

  validates :sorting_id, inclusion: { in: SORTINGS.keys }, allow_nil: false

  scope :having_static_routes, -> { where(sorting_id: SORTINGS_WITH_STATIC_ROUTES) }

  def display_name
    "#{name} | #{id}"
  end

  def sorting_name
    SORTINGS[sorting_id]
  end

  def use_static_routes?
    SORTINGS_WITH_STATIC_ROUTES.include?(sorting_id)
  end

  def have_routing_groups?
    routing_groups.count > 0
  end

  private

  def delete_static_routes
    static_routes.delete_all
  end
end
