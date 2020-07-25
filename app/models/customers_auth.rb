# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.customers_auth
#
#  id                               :integer(4)       not null, primary key
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  capacity                         :integer(2)
#  check_account_balance            :boolean          default(TRUE), not null
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dst_number_max_length            :integer(2)       default(100), not null
#  dst_number_min_length            :integer(2)       default(0), not null
#  dst_number_radius_rewrite_result :string
#  dst_number_radius_rewrite_rule   :string
#  dst_prefix                       :string           default(["\"\""]), is an Array
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  enable_audio_recording           :boolean          default(FALSE), not null
#  enabled                          :boolean          default(TRUE), not null
#  from_domain                      :string           default([]), is an Array
#  ip                               :inet             default(["\"127.0.0.0/8\""]), is an Array
#  name                             :string           not null
#  reject_calls                     :boolean          default(FALSE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_number_max_length            :integer(2)       default(100), not null
#  src_number_min_length            :integer(2)       default(0), not null
#  src_number_radius_rewrite_result :string
#  src_number_radius_rewrite_rule   :string
#  src_prefix                       :string           default(["\"\""]), is an Array
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  tag_action_value                 :integer(2)       default([]), not null, is an Array
#  to_domain                        :string           default([]), is an Array
#  uri_domain                       :string           default([]), is an Array
#  x_yeti_auth                      :string           default([]), is an Array
#  account_id                       :integer(4)
#  customer_id                      :integer(4)       not null
#  diversion_policy_id              :integer(4)       default(1), not null
#  dst_numberlist_id                :integer(2)
#  dump_level_id                    :integer(4)       default(0), not null
#  external_id                      :bigint(8)
#  gateway_id                       :integer(4)       not null
#  lua_script_id                    :integer(2)
#  pop_id                           :integer(4)
#  radius_accounting_profile_id     :integer(2)
#  radius_auth_profile_id           :integer(2)
#  rateplan_id                      :integer(4)       not null
#  routing_plan_id                  :integer(4)       not null
#  src_numberlist_id                :integer(2)
#  tag_action_id                    :integer(2)
#  transport_protocol_id            :integer(2)
#
# Indexes
#
#  customers_auth_external_id_key  (external_id) UNIQUE
#  customers_auth_name_key         (name) UNIQUE
#
# Foreign Keys
#
#  customers_auth_account_id_fkey                    (account_id => accounts.id)
#  customers_auth_customer_id_fkey                   (customer_id => contractors.id)
#  customers_auth_diversion_policy_id_fkey           (diversion_policy_id => diversion_policy.id)
#  customers_auth_dst_blacklist_id_fkey              (dst_numberlist_id => numberlists.id)
#  customers_auth_dump_level_id_fkey                 (dump_level_id => dump_level.id)
#  customers_auth_gateway_id_fkey                    (gateway_id => gateways.id)
#  customers_auth_lua_script_id_fkey                 (lua_script_id => lua_scripts.id)
#  customers_auth_pop_id_fkey                        (pop_id => pops.id)
#  customers_auth_radius_accounting_profile_id_fkey  (radius_accounting_profile_id => radius_accounting_profiles.id)
#  customers_auth_radius_auth_profile_id_fkey        (radius_auth_profile_id => radius_auth_profiles.id)
#  customers_auth_rateplan_id_fkey                   (rateplan_id => rateplans.id)
#  customers_auth_routing_plan_id_fkey               (routing_plan_id => routing_plans.id)
#  customers_auth_src_blacklist_id_fkey              (src_numberlist_id => numberlists.id)
#  customers_auth_tag_action_id_fkey                 (tag_action_id => tag_actions.id)
#  customers_auth_transport_protocol_id_fkey         (transport_protocol_id => transport_protocols.id)
#

class CustomersAuth < Yeti::ActiveRecord
  self.table_name = 'class4.customers_auth'

  module CONST
    MATCH_CONDITION_ATTRIBUTES = %i[ip
                                    src_prefix
                                    dst_prefix
                                    uri_domain
                                    from_domain
                                    to_domain
                                    x_yeti_auth].freeze

    freeze
  end

  belongs_to :customer, -> { where customer: true }, class_name: 'Contractor', foreign_key: :customer_id

  belongs_to :rateplan
  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan'
  belongs_to :gateway
  belongs_to :account
  belongs_to :dump_level
  belongs_to :pop
  belongs_to :diversion_policy
  belongs_to :dst_numberlist, class_name: 'Routing::Numberlist', foreign_key: :dst_numberlist_id
  belongs_to :src_numberlist, class_name: 'Routing::Numberlist', foreign_key: :src_numberlist_id
  belongs_to :radius_auth_profile, class_name: 'Equipment::Radius::AuthProfile', foreign_key: :radius_auth_profile_id
  belongs_to :radius_accounting_profile, class_name: 'Equipment::Radius::AccountingProfile', foreign_key: :radius_accounting_profile_id
  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id

  belongs_to :tag_action, class_name: 'Routing::TagAction'
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id

  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  has_many :destinations, through: :rateplan
  has_many :normalized_copies, class_name: 'CustomersAuthNormalized', foreign_key: :customers_auth_id, dependent: :delete_all

  has_paper_trail class_name: 'AuditLogItem'

  # REDIRECT_METHODS = [
  #     301,
  #     302
  # ]

  validates :ip, :src_prefix, :dst_prefix, :uri_domain, :from_domain, :to_domain, :x_yeti_auth,
            array_format: { without: /\s/, message: 'spaces are not allowed' }

  validates :ip, :src_prefix, :dst_prefix, :uri_domain, :from_domain, :to_domain, :x_yeti_auth,
            array_uniqueness: true

  validates :ip, presence: true

  validates :name, uniqueness: { allow_blank: :false }
  validates :name, presence: true
  validates :external_id, uniqueness: { allow_blank: true }

  validates :customer, :rateplan, :routing_plan, :gateway, :account, :dump_level, :diversion_policy, presence: true

  validates :dst_number_min_length, :dst_number_max_length, :src_number_min_length, :src_number_max_length, presence: true
  validates :src_number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :src_number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :dst_number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :dst_number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }

  validates :capacity, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }

  validate :ip_is_valid
  validate :gateway_supports_incoming_auth

  validates_with TagActionValueValidator

  scope :with_radius, -> { where('radius_auth_profile_id is not null') }
  scope :with_dump, -> { where('dump_level_id > 0') }
  scope :ip_covers, lambda { |ip|
    begin
      IPAddr.new(ip)
    rescue StandardError
      return none
    end
    where(
      "#{table_name}.id IN (
        SELECT customers_auth_id FROM #{CustomersAuthNormalized.table_name} WHERE ip>>='#{ip}'::inet
      )"
    )
  }
  scope :src_prefix_array_contains, ->(src) { where.contains src_prefix: Array(src) }
  scope :dst_prefix_array_contains, ->(dst) { where.contains dst_prefix: Array(dst) }
  scope :uri_domain_array_contains, ->(uri) { where.contains uri_domain: Array(uri) }
  scope :from_domain_array_contains, ->(f_dom) { where.contains from_domain: Array(f_dom) }
  scope :to_domain_array_contains, ->(to_dom) { where.contains to_domain: Array(to_dom) }
  scope :x_yeti_auth_array_contains, ->(auth) { where.contains x_yeti_auth: Array(auth) }

  include Yeti::ResourceStatus

  include PgEvent
  has_pg_queue 'gateway-sync'

  after_create :create_shadow_copy
  after_update :update_shadow_copy

  def display_name
    "#{name} | #{id}"
  end

  # TODO: move to decorator when ActiveAdmin fix problem
  # Problem is:
  # on "update" AA uses decorated object
  # on "create" AA do NOT use decorated object
  CONST::MATCH_CONDITION_ATTRIBUTES.each do |attribute_name|
    define_method "#{attribute_name}=" do |value|
      if value.is_a? String
        value = value.split(',').map(&:strip).reject(&:blank?)
      end
      super(value)
    end
  end

  def display_name_for_debug
    b = "#{customer.display_name} -> #{name} | #{id} IP: #{raw_ip}"
    b += ", Domain: #{uri_domain}" if uri_domain.present?
    b += ", POP: #{pop.try(:name)}" unless pop_id.nil?
    b += ", X-Yeti-Auth: #{x_yeti_auth}" if x_yeti_auth.present?
    b
  end

  # def pop_name
  #   pop.nil? ? "Any" : pop.name
  # end

  def self.search_for_debug(src, dst)
    if src.blank? && dst.blank?
      CustomersAuth.all.reorder(:name)
    elsif src.blank?
      CustomersAuth.where('prefix_range(customers_auth.dst_prefix)@>prefix_range(?)', dst).reorder(:name)
    elsif dst.blank?
      CustomersAuth.where('prefix_range(customers_auth.src_prefix)@>prefix_range(?)', src).reorder(:name)
    else
      CustomersAuth.where("prefix_range(customers_auth.src_prefix)@>prefix_range(?) AND
  prefix_range(customers_auth.dst_prefix)@>prefix_range(?)", src, dst).reorder(:name)
    end
  end

  # force update IP
  def keys_for_partial_write
    (changed + ['ip']).uniq
  end

  private

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      src_prefix_array_contains
      dst_prefix_array_contains
      uri_domain_array_contains
      from_domain_array_contains
      to_domain_array_contains
      x_yeti_auth_array_contains
      ip_covers
    ]
  end

  protected

  def ip_is_valid
    if ip.is_a? Array
      ip.each do |raw_ip|
        _tmp = IPAddr.new(raw_ip)
      end
    end
  rescue IPAddr::Error => error
    errors.add(:ip, 'is not valid')
  end

  def gateway_supports_incoming_auth
    if gateway.try(:incoming_auth_username).blank? && require_incoming_auth
      errors.add(:gateway, I18n.t('activerecord.errors.models.customers_auth.attributes.gateway.incoming_auth_required'))
      errors.add(:require_incoming_auth, I18n.t('activerecord.errors.models.customers_auth.attributes.require_incoming_auth.gateway_with_auth_reqired'))
    end
  end

  def create_shadow_copy
    copy_attributes = { customers_auth_id: id }

    # all other attributes
    CustomersAuthNormalized.shadow_column_names.each do |key|
      copy_attributes[key] = public_send(key)
    end

    if match_conditions_values.empty?
      CustomersAuthNormalized.create!(copy_attributes)
    end

    match_conditions_values.each do |match_conditions_pair|
      # match_conditions attirbutes
      match_conditions_pair.each do |pair|
        key, value = pair.flatten
        copy_attributes[key] = value
      end
      CustomersAuthNormalized.create!(copy_attributes)
    end
  end

  def update_shadow_copy
    # keep it simple: delete all and create again
    normalized_copies.delete_all
    create_shadow_copy
  end

  def match_conditions_values
    @_mcv = begin
              ar_values = CONST::MATCH_CONDITION_ATTRIBUTES.map do |mc_name|
                public_send(mc_name).map { |v| { mc_name => v } }
              end.reject(&:empty?)
              return [] if ar_values.empty?

              first_arr = ar_values.shift
              first_arr.product(*ar_values)
            end
  end
end
