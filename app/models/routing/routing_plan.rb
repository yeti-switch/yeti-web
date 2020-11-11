# frozen_string_literal: true

# == Schema Information
#
# Table name: routing_plans
#
#  id                          :integer(4)       not null, primary key
#  max_rerouting_attempts      :integer(2)       default(10), not null
#  name                        :string           not null
#  rate_delta_max              :decimal(, )      default(0.0), not null
#  use_lnp                     :boolean          default(FALSE), not null
#  validate_dst_number_format  :boolean          default(FALSE), not null
#  validate_dst_number_network :boolean          default(FALSE), not null
#  external_id                 :bigint(8)
#  sorting_id                  :integer(4)       default(1), not null
#
# Indexes
#
#  routing_plans_external_id_key  (external_id) UNIQUE
#  routing_plans_name_key         (name) UNIQUE
#
# Foreign Keys
#
#  routing_plans_sorting_id_fkey  (sorting_id => sortings.id)
#

class Routing::RoutingPlan < Yeti::ActiveRecord
  has_and_belongs_to_many :routing_groups, join_table: 'class4.routing_plan_groups', class_name: 'RoutingGroup'
  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: :routing_plan_id, dependent: :restrict_with_error
  has_many :static_routes, class_name: 'Routing::RoutingPlanStaticRoute',
                           foreign_key: :routing_plan_id, dependent: :delete_all

  has_many :lnp_rules, class_name: 'Lnp::RoutingPlanLnpRule', foreign_key: :routing_plan_id, dependent: :delete_all
  belongs_to :sorting

  has_paper_trail class_name: 'AuditLogItem'

  validates :name, :max_rerouting_attempts, presence: true
  validates :name, uniqueness: { allow_blank: false }
  validates :max_rerouting_attempts, numericality: { greater_than: 0, less_than_or_equal_to: 10, allow_nil: false, only_integer: true }
  validates :external_id, uniqueness: { allow_blank: true }

  scope :having_static_routes, -> { joins(:sorting).merge(Sorting.with_static_routes) }

  def display_name
    "#{name} | #{id}"
  end

  # #todo: remove this
  # def use_lnp_sym
  #   self.use_lnp ?  :true : :false
  # end

  delegate :use_static_routes?, to: :sorting

  def have_routing_groups?
    routing_groups.count > 0
  end

  #  after_update :delete_static_routes, if: proc {|obj| obj.sorting_id_changed? }

  private

  def delete_static_routes
    static_routes.delete_all
  end
end
