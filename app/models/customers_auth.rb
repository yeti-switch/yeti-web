# == Schema Information
#
# Table name: class4.customers_auth
#
#  id                               :integer          not null, primary key
#  customer_id                      :integer          not null
#  rateplan_id                      :integer          not null
#  enabled                          :boolean          default("true"), not null
#  ip                               :inet
#  account_id                       :integer
#  gateway_id                       :integer          not null
#  src_rewrite_rule                 :string
#  src_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  dst_rewrite_result               :string
#  src_prefix                       :string           default(""), not null
#  dst_prefix                       :string           default(""), not null
#  x_yeti_auth                      :string
#  name                             :string           not null
#  dump_level_id                    :integer          default("0"), not null
#  capacity                         :integer
#  pop_id                           :integer
#  uri_domain                       :string
#  src_name_rewrite_rule            :string
#  src_name_rewrite_result          :string
#  diversion_policy_id              :integer          default("1"), not null
#  diversion_rewrite_rule           :string
#  diversion_rewrite_result         :string
#  dst_numberlist_id                :integer
#  src_numberlist_id                :integer
#  routing_plan_id                  :integer          not null
#  allow_receive_rate_limit         :boolean          default("false"), not null
#  send_billing_information         :boolean          default("false"), not null
#  radius_auth_profile_id           :integer
#  enable_audio_recording           :boolean          default("false"), not null
#  src_number_radius_rewrite_rule   :string
#  src_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_number_radius_rewrite_result :string
#  radius_accounting_profile_id     :integer
#  from_domain                      :string
#  to_domain                        :string
#  transport_protocol_id            :integer
#  dst_number_min_length            :integer          default("0"), not null
#  dst_number_max_length            :integer          default("100"), not null
#  check_account_balance            :boolean          default("true"), not null
#  require_incoming_auth            :boolean          default("false"), not null
#  tag_action_id                    :integer
#  tag_action_value                 :integer          default("{}"), not null, is an Array
#

class CustomersAuth < Yeti::ActiveRecord
  self.table_name = 'class4.customers_auth'

  belongs_to :customer, -> { where customer: true }, class_name: 'Contractor', foreign_key: :customer_id

  belongs_to :rateplan
  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan'
  belongs_to :gateway
  belongs_to :account
  belongs_to :dump_level
  belongs_to :pop
  belongs_to :diversion_policy
  belongs_to :dst_numberlist, class_name: Routing::Numberlist, foreign_key: :dst_numberlist_id
  belongs_to :src_numberlist, class_name: Routing::Numberlist, foreign_key: :src_numberlist_id
  belongs_to :radius_auth_profile, class_name: Equipment::Radius::AuthProfile, foreign_key: :radius_auth_profile_id
  belongs_to :radius_accounting_profile, class_name: Equipment::Radius::AccountingProfile, foreign_key: :radius_accounting_profile_id
  belongs_to :transport_protocol, class_name: Equipment::TransportProtocol, foreign_key: :transport_protocol_id

  belongs_to :tag_action, class_name: 'Routing::TagAction'

  has_many :destinations, through: :rateplan

  has_paper_trail class_name: 'AuditLogItem'

  # REDIRECT_METHODS = [
  #     301,
  #     302
  # ]

  validates_format_of :src_prefix, without: /\s/
  validates_format_of :dst_prefix, without: /\s/
  validates_uniqueness_of :name, allow_blank: :false
  validates_presence_of :name
  validates_uniqueness_of :external_id, allow_blank: true

  validates_presence_of :customer, :rateplan, :routing_plan, :gateway, :account, :dump_level, :diversion_policy

  validates_presence_of :dst_number_min_length, :dst_number_max_length
  validates_numericality_of :dst_number_min_length, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true
  validates_numericality_of :dst_number_max_length, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true

  validates_numericality_of :capacity, greater_than: 0, less_than: PG_MAX_SMALLINT, allow_nil: true, only_integer: true

  validate :ip_is_valid
  validate :gateway_supports_incoming_auth

  validates_with TagActionValueValidator

  scope :with_radius, -> { where("radius_auth_profile_id is not null") }
  scope :with_dump, -> { where("dump_level_id > 0") }

  include Yeti::ResourceStatus

  include PgEvent
  has_pg_queue 'gateway-sync'


  scope :ip_covers, lambda { |ip| where("ip>>=?", ip) }

  def display_name
    "#{self.name} | #{self.id}"
  end

  def raw_ip
    read_attribute_before_type_cast('ip')
  end

  def display_name_for_debug
    b="#{self.customer.display_name} -> #{self.name} | #{self.id} IP: #{self.raw_ip}"
    if !self.uri_domain.blank?
      b=b+", Domain: #{self.uri_domain}"
    end
    if !self.pop_id.nil?
      b=b+", POP: #{self.pop.try(:name)}"
    end
    if !self.x_yeti_auth.blank?
      b=b+", X-Yeti-Auth: #{self.x_yeti_auth}"
    end
    b
  end

  # def pop_name
  #   pop.nil? ? "Any" : pop.name
  # end

  def self.search_for_debug(src, dst)
    if src.blank?&&dst.blank?
      CustomersAuth.all.reorder(:name)
    elsif src.blank?
      CustomersAuth.where("prefix_range(customers_auth.dst_prefix)@>prefix_range(?)", dst).reorder(:name)
    elsif dst.blank?
      CustomersAuth.where("prefix_range(customers_auth.src_prefix)@>prefix_range(?)", src).reorder(:name)
    else
      CustomersAuth.where("prefix_range(customers_auth.src_prefix)@>prefix_range(?) AND
  prefix_range(customers_auth.dst_prefix)@>prefix_range(?)", src, dst).reorder(:name)
    end
  end

  #force update IP
  def keys_for_partial_write
    (changed + ['ip']).uniq
  end

  private

  def self.ransackable_scopes(auth_object = nil)
    [
        :ip_covers
    ]
  end

  protected
  def ip_is_valid
    begin
      _tmp=IPAddr.new(raw_ip)
    rescue IPAddr::Error => error
      self.errors.add(:ip, "is not valid")
    end
  end

  def gateway_supports_incoming_auth
    if self.gateway.try(:incoming_auth_username).blank? and self.require_incoming_auth
      self.errors.add(:gateway, I18n.t('activerecord.errors.models.customer_auth.attributes.gateway.incoming_auth_required'))
      self.errors.add(:require_incoming_auth, I18n.t('activerecord.errors.models.customer_auth.attributes.require_incoming_auth.gateway_with_auth_reqired'))
    end
  end
end

