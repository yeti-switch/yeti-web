# == Schema Information
#
# Table name: routing_plans
#
#  id                     :integer          not null, primary key
#  name                   :string           not null
#  sorting_id             :integer          default(1), not null
#  rate_delta_max         :decimal(, )      default(0.0), not null
#  use_lnp                :boolean          default(FALSE), not null
#  max_rerouting_attempts :integer          default(10), not null
#

class Routing::RoutingPlan < Yeti::ActiveRecord
  has_and_belongs_to_many :routing_groups, join_table: "class4.routing_plan_groups", class_name: 'RoutingGroup'
  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: :routing_plan_id, dependent: :restrict_with_error
  has_many :static_routes, class_name: 'Routing::RoutingPlanStaticRoute',
           foreign_key: :routing_plan_id, dependent: :delete_all

  has_many :lnp_rules, class_name: 'Lnp::RoutingPlanLnpRule', foreign_key: :routing_plan_id, dependent: :delete_all
  belongs_to :sorting

  has_paper_trail class_name: 'AuditLogItem'

  validates_presence_of :name, :max_rerouting_attempts
  validates_uniqueness_of  :name, allow_blank: false
  validates_numericality_of :max_rerouting_attempts, greater_than: 0, less_than_or_equal_to: 10, allow_nil: false, only_integer: true

  scope :having_static_routes, -> { joins(:sorting).merge( Sorting.with_static_routes ) }

  def display_name
    "#{self.name} | #{self.id}"
  end

  # #todo: remove this
  # def use_lnp_sym
  #   self.use_lnp ?  :true : :false
  # end

  def use_static_routes?
    self.sorting.use_static_routes?
  end

  def have_routing_groups?
    routing_groups.count>0
  end

#  after_update :delete_static_routes, if: proc {|obj| obj.sorting_id_changed? }

  private

  def delete_static_routes
    self.static_routes.delete_all
  end

end

