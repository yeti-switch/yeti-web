# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.customers_auth
#
#  id                               :integer(4)       not null, primary key
#  allow_receive_rate_limit         :boolean          default(FALSE), not null
#  capacity                         :integer(2)
#  check_account_balance            :boolean          default(TRUE), not null
#  cps_limit                        :float
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
#  external_type                    :string
#  from_domain                      :string           default([]), is an Array
#  interface                        :string           default([]), not null, is an Array
#  ip                               :inet             default(["\"127.0.0.0/8\""]), is an Array
#  name                             :string           not null
#  pai_rewrite_result               :string
#  pai_rewrite_rule                 :string
#  reject_calls                     :boolean          default(FALSE), not null
#  require_incoming_auth            :boolean          default(FALSE), not null
#  send_billing_information         :boolean          default(FALSE), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_number_max_length            :integer(2)       default(100), not null
#  src_number_min_length            :integer(2)       default(0), not null
#  src_number_radius_rewrite_result :string
#  src_number_radius_rewrite_rule   :string
#  src_numberlist_use_diversion     :boolean          default(FALSE), not null
#  src_prefix                       :string           default(["\"\""]), is an Array
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  ss_dst_rewrite_result            :string
#  ss_dst_rewrite_rule              :string
#  ss_src_rewrite_result            :string
#  ss_src_rewrite_rule              :string
#  tag_action_value                 :integer(2)       default([]), not null, is an Array
#  to_domain                        :string           default([]), is an Array
#  uri_domain                       :string           default([]), is an Array
#  x_yeti_auth                      :string           default([]), is an Array
#  account_id                       :integer(4)
#  cnam_database_id                 :integer(2)
#  customer_id                      :integer(4)       not null
#  diversion_policy_id              :integer(2)       default(1), not null
#  dst_number_field_id              :integer(2)       default(1), not null
#  dst_numberlist_id                :integer(4)
#  dump_level_id                    :integer(2)       default(0), not null
#  external_id                      :bigint(8)
#  gateway_id                       :integer(4)       not null
#  lua_script_id                    :integer(2)
#  pai_policy_id                    :integer(2)       default(1), not null
#  pop_id                           :integer(4)
#  privacy_mode_id                  :integer(2)       default(1), not null
#  radius_accounting_profile_id     :integer(2)
#  radius_auth_profile_id           :integer(2)
#  rateplan_id                      :integer(4)       not null
#  rewrite_ss_status_id             :integer(2)
#  routing_plan_id                  :integer(4)       not null
#  src_name_field_id                :integer(2)       default(1), not null
#  src_number_field_id              :integer(2)       default(1), not null
#  src_numberlist_id                :integer(4)
#  ss_invalid_identity_action_id    :integer(2)       default(0), not null
#  ss_mode_id                       :integer(2)       default(0), not null
#  ss_no_identity_action_id         :integer(2)       default(0), not null
#  stir_shaken_crt_id               :integer(2)
#  tag_action_id                    :integer(2)
#  transport_protocol_id            :integer(2)
#
# Indexes
#
#  customers_auth_account_id_idx                      (account_id)
#  customers_auth_customer_id_idx                     (customer_id)
#  customers_auth_dst_numberlist_id_idx               (dst_numberlist_id)
#  customers_auth_external_id_external_type_key_uniq  (external_id,external_type) UNIQUE
#  customers_auth_external_id_key_uniq                (external_id) UNIQUE WHERE (external_type IS NULL)
#  customers_auth_name_key                            (name) UNIQUE
#  customers_auth_src_numberlist_id_idx               (src_numberlist_id)
#
# Foreign Keys
#
#  customers_auth_account_id_fkey                    (account_id => accounts.id)
#  customers_auth_cnam_database_id_fkey              (cnam_database_id => cnam_databases.id)
#  customers_auth_customer_id_fkey                   (customer_id => contractors.id)
#  customers_auth_dst_blacklist_id_fkey              (dst_numberlist_id => numberlists.id)
#  customers_auth_gateway_id_fkey                    (gateway_id => gateways.id)
#  customers_auth_lua_script_id_fkey                 (lua_script_id => lua_scripts.id)
#  customers_auth_pop_id_fkey                        (pop_id => pops.id)
#  customers_auth_radius_accounting_profile_id_fkey  (radius_accounting_profile_id => radius_accounting_profiles.id)
#  customers_auth_radius_auth_profile_id_fkey        (radius_auth_profile_id => radius_auth_profiles.id)
#  customers_auth_rateplan_id_fkey                   (rateplan_id => rateplans.id)
#  customers_auth_routing_plan_id_fkey               (routing_plan_id => routing_plans.id)
#  customers_auth_src_blacklist_id_fkey              (src_numberlist_id => numberlists.id)
#  customers_auth_tag_action_id_fkey                 (tag_action_id => tag_actions.id)
#

class CustomersAuth < ApplicationRecord
  self.table_name = 'class4.customers_auth'

  TRANSPORT_PROTOCOL_UDP = 1
  TRANSPORT_PROTOCOL_TCP = 2
  TRANSPORT_PROTOCOL_TLS = 3
  TRANSPORT_PROTOCOLS = {
    TRANSPORT_PROTOCOL_UDP => 'UDP',
    TRANSPORT_PROTOCOL_TCP => 'TCP',
    TRANSPORT_PROTOCOL_TLS => 'TLS'
  }.freeze

  DUMP_LEVEL_DISABLED = 0
  DUMP_LEVEL_CAPTURE_SIP = 1
  DUMP_LEVEL_CAPTURE_RTP = 2
  DUMP_LEVEL_CAPTURE_ALL = 3
  DUMP_LEVELS = {
    DUMP_LEVEL_DISABLED => 'Disabled',
    DUMP_LEVEL_CAPTURE_SIP => 'SIP',
    DUMP_LEVEL_CAPTURE_RTP => 'RTP',
    DUMP_LEVEL_CAPTURE_ALL => 'SIP and RTP'
  }.freeze

  SS_MODE_DISABLE = 0
  SS_MODE_VALIDATE = 1
  SS_MODE_REWRITE = 2
  SS_MODES = {
    SS_MODE_DISABLE => 'Disable STIR/SHAKEN processing',
    SS_MODE_VALIDATE => 'Validate identity',
    SS_MODE_REWRITE => 'Force rewrite attestation level'
  }.freeze

  SS_NO_IDENTITY_ACTION_NOTHING = 0
  SS_NO_IDENTITY_ACTION_REJECT = 1
  SS_NO_IDENTITY_ACTION_REWRITE = 2
  SS_NO_IDENTITY_ACTIONS = {
    SS_NO_IDENTITY_ACTION_NOTHING => 'Do nothing',
    SS_NO_IDENTITY_ACTION_REJECT => 'Reject call',
    SS_NO_IDENTITY_ACTION_REWRITE => 'Rewrite'
  }.freeze

  SS_INVALID_IDENTITY_ACTION_NOTHING = 0
  SS_INVALID_IDENTITY_ACTION_REJECT = 1
  SS_INVALID_IDENTITY_ACTION_REWRITE = 2
  SS_INVALID_IDENTITY_ACTIONS = {
    SS_INVALID_IDENTITY_ACTION_NOTHING => 'Do nothing',
    SS_INVALID_IDENTITY_ACTION_REJECT => 'Reject call',
    SS_INVALID_IDENTITY_ACTION_REWRITE => 'Rewrite'
  }.freeze

  PRIVACY_MODE_ALLOW = 1
  PRIVACY_MODE_REJECT = 2
  PRIVACY_MODE_REJECT_CRITICAL = 3
  PRIVACY_MODE_REJECT_ANONYMOUS = 4
  PRIVACY_MODES = {
    PRIVACY_MODE_ALLOW => 'Allow any calls',
    PRIVACY_MODE_REJECT => 'Reject private calls',
    PRIVACY_MODE_REJECT_CRITICAL => 'Reject critical private calls',
    PRIVACY_MODE_REJECT_ANONYMOUS => 'Reject anonymous(no CLI/PAI/PPI)'
  }.freeze

  DIVERSION_POLICY_NOT_ACCEPT = 1
  DIVERSION_POLICY_ACCEPT = 2
  DIVERSION_POLICIES = {
    DIVERSION_POLICY_NOT_ACCEPT => 'Do not accept',
    DIVERSION_POLICY_ACCEPT => 'Accept'
  }.freeze

  PAI_POLICY_NOT_ACCEPT = 0
  PAI_POLICY_ACCEPT = 1
  PAI_POLICY_REQUIRE = 2
  PAI_POLICIES = {
    PAI_POLICY_NOT_ACCEPT => 'Do not accept',
    PAI_POLICY_ACCEPT => 'Accept',
    PAI_POLICY_REQUIRE => 'Require'
  }.freeze

  DST_NUMBER_FIELD_RURI_USERPART = 1
  DST_NUMBER_FIELD_TO_USERPART = 2
  DST_NUMBER_FIELD_DIVERSION_USERPART = 3
  DST_NUMBER_FIELDS = {
    DST_NUMBER_FIELD_RURI_USERPART => 'R-URI userpart',
    DST_NUMBER_FIELD_TO_USERPART => 'To URI userpart',
    DST_NUMBER_FIELD_DIVERSION_USERPART => 'Top Diversion header userpart'
  }.freeze

  SRC_NUMBER_FIELD_FROM_USERPART = 1
  SRC_NUMBER_FIELD_FROM_DSP = 2
  SRC_NUMBER_FIELDS = {
    SRC_NUMBER_FIELD_FROM_USERPART => 'From URI userpart',
    SRC_NUMBER_FIELD_FROM_DSP => 'From URI display name'
  }.freeze

  SRC_NAME_FIELD_FROM_DSP = 1
  SRC_NAME_FIELD_FROM_USERPART = 2
  SRC_NAME_FIELDS = {
    SRC_NAME_FIELD_FROM_DSP => 'From URI display name',
    SRC_NAME_FIELD_FROM_USERPART => 'From URI userpart'
  }.freeze

  module CONST
    MATCH_CONDITION_ATTRIBUTES = %i[ip
                                    src_prefix
                                    dst_prefix
                                    uri_domain
                                    from_domain
                                    to_domain
                                    x_yeti_auth
                                    interface].freeze

    freeze
  end

  attribute :external_type, :string_presence

  belongs_to :customer, -> { where customer: true }, class_name: 'Contractor', foreign_key: :customer_id

  belongs_to :rateplan, class_name: 'Routing::Rateplan'
  has_many :destinations, class_name: 'Routing::Destination', through: :rateplan

  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan'
  belongs_to :gateway
  belongs_to :account, optional: true
  belongs_to :pop, optional: true
  belongs_to :dst_numberlist, class_name: 'Routing::Numberlist', foreign_key: :dst_numberlist_id, optional: true
  belongs_to :src_numberlist, class_name: 'Routing::Numberlist', foreign_key: :src_numberlist_id, optional: true
  belongs_to :radius_auth_profile, class_name: 'Equipment::Radius::AuthProfile', foreign_key: :radius_auth_profile_id, optional: true
  belongs_to :radius_accounting_profile, class_name: 'Equipment::Radius::AccountingProfile', foreign_key: :radius_accounting_profile_id, optional: true

  belongs_to :tag_action, class_name: 'Routing::TagAction', optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true

  belongs_to :cnam_database, class_name: 'Cnam::Database', foreign_key: :cnam_database_id, optional: true
  belongs_to :stir_shaken_crt, class_name: 'Equipment::StirShaken::SigningCertificate', foreign_key: :stir_shaken_crt_id, optional: :true

  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  has_many :traffic_sampling_rules, class_name: 'Routing::TrafficSamplingRule', foreign_key: :customers_auth_id, dependent: :destroy

  has_many :normalized_copies, class_name: 'CustomersAuthNormalized', foreign_key: :customers_auth_id, dependent: :delete_all

  include WithPaperTrail

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

  validates :external_type, absence: { message: 'requires external_id' }, unless: :external_id
  validates :external_id,
            uniqueness: { scope: :external_type },
            if: proc { external_id && external_type }
  validates :external_id,
            uniqueness: { conditions: -> { where(external_type: nil) } },
            if: proc { external_id && !external_type }

  validates :customer, :rateplan, :routing_plan, :gateway, :account, presence: true
  validate :validate_account
  validate :validate_gateway

  validates :dst_number_min_length, :dst_number_max_length, :src_number_min_length, :src_number_max_length, presence: true
  validates :src_number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :src_number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :dst_number_min_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }
  validates :dst_number_max_length, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false, only_integer: true }

  validates :capacity, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }
  validates :cps_limit, numericality: { greater_than_or_equal_to: 0.01, allow_nil: true }

  validate :ip_is_valid
  validate :gateway_supports_incoming_auth

  validates :dump_level_id, :diversion_policy_id, :pai_policy_id, presence: true
  validates :dump_level_id, inclusion: { in: CustomersAuth::DUMP_LEVELS.keys }, allow_nil: false
  validates :diversion_policy_id, inclusion: { in: CustomersAuth::DIVERSION_POLICIES.keys }, allow_nil: false
  validates :pai_policy_id, inclusion: { in: CustomersAuth::PAI_POLICIES.keys }, allow_nil: false

  validates :rewrite_ss_status_id, inclusion: { in: Equipment::StirShaken::Attestation::ATTESTATIONS.keys }, allow_nil: true
  validate :validate_rewrite_ss_status
  validates :privacy_mode_id, inclusion: { in: PRIVACY_MODES.keys }, allow_nil: false

  validates :src_name_field_id, :src_number_field_id, :dst_number_field_id, presence: true

  validates :src_name_field_id, inclusion: { in: CustomersAuth::SRC_NAME_FIELDS.keys }, allow_nil: false
  validates :src_number_field_id, inclusion: { in: CustomersAuth::SRC_NUMBER_FIELDS.keys }, allow_nil: false
  validates :dst_number_field_id, inclusion: { in: CustomersAuth::DST_NUMBER_FIELDS.keys }, allow_nil: false

  validates :transport_protocol_id, inclusion: { in: CustomersAuth::TRANSPORT_PROTOCOLS.keys }, allow_nil: true

  validates_with TagActionValueValidator

  include Yeti::StateUpdater
  self.state_names = ['customers_auth']

  scope :with_radius, -> { where('class4.customers_auth.radius_auth_profile_id is not null') }
  scope :with_dump, -> { where('class4.customers_auth.dump_level_id > 0') }
  scope :with_recording, -> { where('class4.customers_auth.enable_audio_recording') }

  scope :ip_covers, lambda { |ip|
    begin
      IPAddr.new(ip)
    rescue StandardError
      return none
    end
    # customers_auth IP subnet contain or equal subnet from filter
    where(
      "#{table_name}.id IN (
        SELECT customers_auth_id FROM #{CustomersAuthNormalized.table_name} WHERE ip>>=?::inet
      )", ip
    )
  }
  scope :src_prefix_array_contains, ->(src) { where.contains src_prefix: Array(src) }
  scope :dst_prefix_array_contains, ->(dst) { where.contains dst_prefix: Array(dst) }
  scope :uri_domain_array_contains, ->(uri) { where.contains uri_domain: Array(uri) }
  scope :from_domain_array_contains, ->(f_dom) { where.contains from_domain: Array(f_dom) }
  scope :to_domain_array_contains, ->(to_dom) { where.contains to_domain: Array(to_dom) }
  scope :x_yeti_auth_array_contains, ->(auth) { where.contains x_yeti_auth: Array(auth) }
  scope :search_for, ->(term) { where("class4.customers_auth.name || ' | ' || class4.customers_auth.id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }

  include Yeti::ResourceStatus

  include PgEvent
  has_pg_queue 'gateway-sync'

  after_create :create_shadow_copy
  after_update :update_shadow_copy

  def display_name
    "#{name} | #{id}"
  end

  def transport_protocol_name
    transport_protocol_id.nil? ? 'Any' : TRANSPORT_PROTOCOLS[transport_protocol_id]
  end

  def dump_level_name
    dump_level_id.nil? ? DUMP_LEVELS[0] : DUMP_LEVELS[dump_level_id]
  end

  def rewrite_ss_status_name
    rewrite_ss_status_id.nil? ? nil : Equipment::StirShaken::Attestation::ATTESTATIONS[rewrite_ss_status_id]
  end

  def ss_mode_name
    ss_mode_id.nil? ? nil : SS_MODES[ss_mode_id]
  end

  def ss_invalid_identity_action_name
    ss_invalid_identity_action_id.nil? ? nil : SS_INVALID_IDENTITY_ACTIONS[ss_invalid_identity_action_id]
  end

  def ss_no_identity_action_name
    ss_no_identity_action_id.nil? ? nil : SS_NO_IDENTITY_ACTIONS[ss_no_identity_action_id]
  end

  def pai_policy_name
    PAI_POLICIES[pai_policy_id]
  end

  def diversion_policy_name
    DIVERSION_POLICIES[diversion_policy_id]
  end

  def dst_number_field_name
    DST_NUMBER_FIELDS[dst_number_field_id]
  end

  def src_number_field_name
    SRC_NUMBER_FIELDS[src_number_field_id]
  end

  def src_name_field_name
    SRC_NAME_FIELDS[src_name_field_id]
  end

  def privacy_mode_name
    PRIVACY_MODES[privacy_mode_id]
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

  # force update IP
  def keys_for_partial_write
    (changed + ['ip']).uniq
  end

  private

  def validate_account
    return if customer.nil? || account.nil?

    errors.add(:account, 'belongs to different customer') if account.contractor_id != customer_id
  end

  def validate_gateway
    return if customer.nil? || gateway.nil?

    errors.add(:gateway, 'belongs to different customer') if !gateway.is_shared && gateway.contractor_id != customer_id
  end

  def validate_rewrite_ss_status
    return unless rewrite_ss_status_id.nil?

    if ss_mode_id == SS_MODE_REWRITE ||
       ss_no_identity_action_id == SS_NO_IDENTITY_ACTION_REWRITE ||
       ss_invalid_identity_action_id == SS_INVALID_IDENTITY_ACTION_REWRITE
      errors.add(:rewrite_ss_status_id, 'Rewrite status should be defined for selected mode')
    end
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      src_prefix_array_contains
      dst_prefix_array_contains
      uri_domain_array_contains
      from_domain_array_contains
      to_domain_array_contains
      x_yeti_auth_array_contains
      ip_covers
      search_for
      ordered_by
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
    if gateway.try(:incoming_auth_username).blank? && gateway.try(:incoming_auth_allow_jwt) == false && require_incoming_auth
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
