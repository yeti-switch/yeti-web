# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateways
#
#  id                               :integer(4)       not null, primary key
#  acd_limit                        :float(24)        default(0.0), not null
#  allow_1xx_without_to_tag         :boolean          default(FALSE), not null
#  allow_origination                :boolean          default(TRUE), not null
#  allow_termination                :boolean          default(TRUE), not null
#  asr_limit                        :float(24)        default(0.0), not null
#  auth_enabled                     :boolean          default(FALSE), not null
#  auth_from_domain                 :string
#  auth_from_user                   :string
#  auth_password                    :string
#  auth_user                        :string
#  codecs_payload_order             :string           default("")
#  codecs_prefer_transcoding_for    :string           default("")
#  dialog_nat_handling              :boolean          default(TRUE), not null
#  diversion_domain                 :string
#  diversion_rewrite_result         :string
#  diversion_rewrite_rule           :string
#  dns_srv_failover_timer           :integer(4)       default(2000), not null
#  dst_rewrite_result               :string
#  dst_rewrite_rule                 :string
#  enabled                          :boolean          not null
#  fake_180_timer                   :integer(2)
#  filter_noaudio_streams           :boolean          default(FALSE), not null
#  force_cancel_routeset            :boolean          default(FALSE), not null
#  force_dtmf_relay                 :boolean          default(FALSE), not null
#  force_one_way_early_media        :boolean          default(FALSE), not null
#  force_symmetric_rtp              :boolean          default(TRUE), not null
#  host                             :string
#  incoming_auth_allow_jwt          :boolean          default(FALSE), not null
#  incoming_auth_password           :string
#  incoming_auth_username           :string
#  is_shared                        :boolean          default(FALSE), not null
#  locked                           :boolean          default(FALSE), not null
#  max_30x_redirects                :integer(2)       default(0), not null
#  max_transfers                    :integer(2)       default(0), not null
#  name                             :string           not null
#  orig_append_headers_reply        :string           default([]), not null, is an Array
#  orig_append_headers_req          :string           default([]), not null, is an Array
#  orig_force_outbound_proxy        :boolean          default(FALSE), not null
#  orig_next_hop                    :string
#  orig_outbound_proxy              :string
#  orig_use_outbound_proxy          :boolean          default(FALSE), not null
#  origination_capacity             :integer(2)
#  pai_domain                       :string
#  port                             :integer(4)
#  prefer_existing_codecs           :boolean          default(TRUE), not null
#  preserve_anonymous_from_domain   :boolean          default(FALSE), not null
#  priority                         :integer(4)       default(100), not null
#  proxy_media                      :boolean          default(TRUE), not null
#  relay_hold                       :boolean          default(FALSE), not null
#  relay_options                    :boolean          default(FALSE), not null
#  relay_prack                      :boolean          default(FALSE), not null
#  relay_reinvite                   :boolean          default(FALSE), not null
#  relay_update                     :boolean          default(FALSE), not null
#  resolve_ruri                     :boolean          default(FALSE), not null
#  ringing_timeout                  :integer(4)
#  rtp_acl                          :inet             is an Array
#  rtp_force_relay_cn               :boolean          default(TRUE), not null
#  rtp_interface_name               :string
#  rtp_ping                         :boolean          default(FALSE), not null
#  rtp_relay_timestamp_aligning     :boolean          default(FALSE), not null
#  rtp_timeout                      :integer(4)       default(30), not null
#  sdp_alines_filter_list           :string
#  send_lnp_information             :boolean          default(FALSE), not null
#  short_calls_limit                :float(24)        default(1.0), not null
#  single_codec_in_200ok            :boolean          default(FALSE), not null
#  sip_interface_name               :string
#  sip_timer_b                      :integer(4)       default(8000), not null
#  src_name_rewrite_result          :string
#  src_name_rewrite_rule            :string
#  src_rewrite_result               :string
#  src_rewrite_rule                 :string
#  sst_accept501                    :boolean          default(TRUE), not null
#  sst_enabled                      :boolean          default(FALSE)
#  sst_maximum_timer                :integer(4)       default(50), not null
#  sst_minimum_timer                :integer(4)       default(50), not null
#  sst_session_expires              :integer(4)       default(50)
#  suppress_early_media             :boolean          default(FALSE), not null
#  symmetric_rtp_nonstop            :boolean          default(FALSE), not null
#  term_append_headers_req          :string           default([]), not null, is an Array
#  term_force_outbound_proxy        :boolean          default(FALSE), not null
#  term_next_hop                    :string
#  term_next_hop_for_replies        :boolean          default(FALSE), not null
#  term_outbound_proxy              :string
#  term_use_outbound_proxy          :boolean          default(FALSE), not null
#  termination_capacity             :integer(2)
#  termination_cps_limit            :integer(2)
#  termination_cps_wsize            :integer(2)       default(1), not null
#  termination_subscriber_capacity  :integer(2)
#  termination_subscriber_cps_limit :integer(2)
#  termination_subscriber_cps_wsize :integer(2)       default(1), not null
#  to_rewrite_result                :string
#  to_rewrite_rule                  :string
#  transfer_append_headers_req      :string           default([]), not null, is an Array
#  transfer_tel_uri_host            :string
#  transit_headers_from_origination :string
#  transit_headers_from_termination :string
#  try_avoid_transcoding            :boolean          default(FALSE), not null
#  uuid                             :uuid             not null
#  weight                           :integer(2)       default(100), not null
#  codec_group_id                   :integer(4)       default(1), not null
#  contractor_id                    :integer(4)       not null
#  diversion_send_mode_id           :integer(2)       default(1), not null
#  dtmf_receive_mode_id             :integer(2)       default(1), not null
#  dtmf_send_mode_id                :integer(2)       default(1), not null
#  dump_level_id                    :integer(2)       default(0), not null
#  external_id                      :bigint(8)
#  gateway_group_id                 :integer(4)
#  lua_script_id                    :integer(2)
#  media_encryption_mode_id         :integer(2)       default(0), not null
#  network_protocol_priority_id     :integer(2)       default(0), not null
#  orig_disconnect_policy_id        :integer(4)
#  orig_proxy_transport_protocol_id :integer(2)       default(1), not null
#  pai_send_mode_id                 :integer(2)       default(0), not null
#  pop_id                           :integer(4)
#  privacy_mode_id                  :integer(2)       default(0), not null
#  radius_accounting_profile_id     :integer(2)
#  registered_aor_mode_id           :integer(2)       default(0), not null
#  rel100_mode_id                   :integer(2)       default(4), not null
#  rx_inband_dtmf_filtering_mode_id :integer(2)       default(1), not null
#  scheduler_id                     :integer(2)
#  sdp_alines_filter_type_id        :integer(4)       default(0), not null
#  sdp_c_location_id                :integer(4)       default(2), not null
#  sensor_id                        :integer(2)
#  sensor_level_id                  :integer(2)       default(1), not null
#  session_refresh_method_id        :integer(4)       default(3), not null
#  sip_schema_id                    :integer(2)       default(1), not null
#  stir_shaken_crt_id               :integer(2)
#  stir_shaken_mode_id              :integer(2)       default(0), not null
#  term_disconnect_policy_id        :integer(4)
#  term_proxy_transport_protocol_id :integer(2)       default(1), not null
#  termination_dst_numberlist_id    :integer(4)
#  termination_src_numberlist_id    :integer(4)
#  throttling_profile_id            :integer(2)
#  transparent_dialog_id            :boolean          default(FALSE), not null
#  transport_protocol_id            :integer(2)       default(1), not null
#  tx_inband_dtmf_filtering_mode_id :integer(2)       default(1), not null
#
# Indexes
#
#  gateways_contractor_id_idx          (contractor_id)
#  gateways_dst_numberlist_id_idx      (termination_dst_numberlist_id)
#  gateways_name_unique                (name) UNIQUE
#  gateways_scheduler_id_idx           (scheduler_id)
#  gateways_src_numberlist_id_idx      (termination_src_numberlist_id)
#  gateways_throttling_profile_id_idx  (throttling_profile_id)
#
# Foreign Keys
#
#  gateways_codec_group_id_fkey                    (codec_group_id => codec_groups.id)
#  gateways_contractor_id_fkey                     (contractor_id => contractors.id)
#  gateways_diversion_send_mode_id_fkey            (diversion_send_mode_id => gateway_diversion_send_modes.id)
#  gateways_dtmf_receive_mode_id_fkey              (dtmf_receive_mode_id => dtmf_receive_modes.id)
#  gateways_dtmf_send_mode_id_fkey                 (dtmf_send_mode_id => dtmf_send_modes.id)
#  gateways_gateway_group_id_fkey                  (gateway_group_id => gateway_groups.id)
#  gateways_lua_script_id_fkey                     (lua_script_id => lua_scripts.id)
#  gateways_media_encryption_mode_id_fkey          (media_encryption_mode_id => gateway_media_encryption_modes.id)
#  gateways_network_protocol_priority_id_fkey      (network_protocol_priority_id => gateway_network_protocol_priorities.id)
#  gateways_orig_disconnect_policy_id_fkey         (orig_disconnect_policy_id => disconnect_policy.id)
#  gateways_orig_proxy_transport_protocol_id_fkey  (orig_proxy_transport_protocol_id => transport_protocols.id)
#  gateways_pop_id_fkey                            (pop_id => pops.id)
#  gateways_radius_accounting_profile_id_fkey      (radius_accounting_profile_id => radius_accounting_profiles.id)
#  gateways_rel100_mode_id_fkey                    (rel100_mode_id => gateway_rel100_modes.id)
#  gateways_rx_inband_dtmf_filtering_mode_id_fkey  (rx_inband_dtmf_filtering_mode_id => gateway_inband_dtmf_filtering_modes.id)
#  gateways_scheduler_id_fkey                      (scheduler_id => schedulers.id)
#  gateways_sdp_alines_filter_type_id_fkey         (sdp_alines_filter_type_id => filter_types.id)
#  gateways_sdp_c_location_id_fkey                 (sdp_c_location_id => sdp_c_location.id)
#  gateways_sensor_id_fkey                         (sensor_id => sensors.id)
#  gateways_sensor_level_id_fkey                   (sensor_level_id => sensor_levels.id)
#  gateways_session_refresh_method_id_fkey         (session_refresh_method_id => session_refresh_methods.id)
#  gateways_stir_shaken_crt_id_fkey                (stir_shaken_crt_id => stir_shaken_signing_certificates.id)
#  gateways_term_disconnect_policy_id_fkey         (term_disconnect_policy_id => disconnect_policy.id)
#  gateways_term_proxy_transport_protocol_id_fkey  (term_proxy_transport_protocol_id => transport_protocols.id)
#  gateways_termination_dst_numberlist_id_fkey     (termination_dst_numberlist_id => numberlists.id)
#  gateways_termination_src_numberlist_id_fkey     (termination_src_numberlist_id => numberlists.id)
#  gateways_throttling_profile_id_fkey             (throttling_profile_id => gateway_throttling_profiles.id)
#  gateways_transport_protocol_id_fkey             (transport_protocol_id => transport_protocols.id)
#  gateways_tx_inband_dtmf_filtering_mode_id_fkey  (tx_inband_dtmf_filtering_mode_id => gateway_inband_dtmf_filtering_modes.id)
#

require 'resolv'

class Gateway < ApplicationRecord
  self.table_name = 'class4.gateways'

  RTP_TIMEOUT_MIN = 0
  RTP_TIMEOUT_MAX = 600

  PAI_SEND_MODE_NO_SEND = 0
  PAI_SEND_MODE_BUILD_TEL = 1
  PAI_SEND_MODE_BUILD_SIP = 2
  PAI_SEND_MODE_BUILD_SIP_WITH_USER_PHONE = 3
  PAI_SEND_MODE_RELAY = 4
  PAI_SEND_MODE_RELAY_AS_TEL = 5
  PAI_SEND_MODE_RELAY_AS_SIP = 6
  PAI_SEND_MODE_RELAY_AS_SIP_FORCE_DOMAIN = 7
  PAI_SEND_MODES = {
    PAI_SEND_MODE_NO_SEND => 'Do not send',
    PAI_SEND_MODE_BUILD_TEL => 'Build TEL URI from Source Number',
    PAI_SEND_MODE_BUILD_SIP => 'Build SIP URI from Source Number',
    PAI_SEND_MODE_BUILD_SIP_WITH_USER_PHONE => 'Build SIP URI from Source Number with user=phone',
    PAI_SEND_MODE_RELAY => 'Relay PAI/PPI as is',
    PAI_SEND_MODE_RELAY_AS_TEL => 'Relay PAI/PPI as TEL uri',
    PAI_SEND_MODE_RELAY_AS_SIP => 'Relay PAI/PPI as SIP uri',
    PAI_SEND_MODE_RELAY_AS_SIP_FORCE_DOMAIN => 'Relay PAI/PPI as SIP uri. Replace domain'
  }.freeze

  REGISTERED_AOR_MODE_NO_USE = 0
  REGISTERED_AOR_MODE_AS_IS = 1
  REGISTERED_AOR_MODE_REPLACE_USERPART = 2
  REGISTERED_AOR_MODES = {
    REGISTERED_AOR_MODE_NO_USE => 'Do not use',
    REGISTERED_AOR_MODE_AS_IS => 'Use AOR as is',
    REGISTERED_AOR_MODE_REPLACE_USERPART => 'Use AOR, replace userpart with dst number'
  }.freeze

  STIR_SHAKEN_MODE_DISABLE = 0
  STIR_SHAKEN_MODE_RELAY_INSERT = 1
  STIR_SHAKEN_MODE_RELAY_INSERT_OUT = 2
  STIR_SHAKEN_MODES = {
    STIR_SHAKEN_MODE_DISABLE => 'Disable',
    STIR_SHAKEN_MODE_RELAY_INSERT => 'Relay valid identity or insert our identity(routing numbers)',
    STIR_SHAKEN_MODE_RELAY_INSERT_OUT => 'Relay valid identity or insert our identity(out numbers)'
  }.freeze

  SIP_SCHEMA_SIP = 1
  SIP_SCHEMA_SIPS = 2
  SIP_SCHEMA_SIP_WITH_USER_PHONE = 3
  SIP_SCHEMAS = {
    SIP_SCHEMA_SIP => 'sip',
    SIP_SCHEMA_SIPS => 'sips',
    SIP_SCHEMA_SIP_WITH_USER_PHONE => 'sip with user=phone'
  }.freeze

  PRIVACY_MODE_DISABLE = 0
  PRIVACY_MODE_SKIP = 1
  PRIVACY_MODE_SKIP_CRITICAL = 2
  PRIVACY_MODE_APPLY = 3
  PRIVACY_MODE_TRUSTED = 4
  PRIVACY_MODE_TRUSTED_REMOVE_FROM = 5
  PRIVACY_MODES = {
    PRIVACY_MODE_DISABLE => 'Do nothing',
    PRIVACY_MODE_SKIP => 'Skip for private calls',
    PRIVACY_MODE_SKIP_CRITICAL => 'Skip for critical private calls',
    PRIVACY_MODE_APPLY => 'Not trusted gw. Apply',
    PRIVACY_MODE_TRUSTED => 'Trusted gw. Forward',
    PRIVACY_MODE_TRUSTED_REMOVE_FROM => 'Trusted gw. Forward. Anonymize from'
  }.freeze

  DUMP_LEVEL_DISABLED = 0
  DUMP_LEVEL_CAPTURE_SIP = 1
  DUMP_LEVEL_CAPTURE_RTP = 2
  DUMP_LEVEL_CAPTURE_ALL = 3
  DUMP_LEVELS = {
    DUMP_LEVEL_DISABLED => 'Capture nothing',
    DUMP_LEVEL_CAPTURE_SIP => 'Capture signaling traffic',
    DUMP_LEVEL_CAPTURE_RTP => 'Capture RTP traffic',
    DUMP_LEVEL_CAPTURE_ALL => 'Capture all traffic'
  }.freeze

  class << self
    # Returns a reference if host is IPv6, otherwise returns host
    # @param value [String]
    # @return [String]
    def normalize_host(value)
      ip_addr = IPAddr.new(value)
      ip_addr.ipv6? ? "[#{ip_addr}]" : value
    rescue IPAddr::Error => _e
      value
    end
  end

  belongs_to :contractor
  belongs_to :vendor, -> { vendors }, class_name: 'Contractor', foreign_key: :contractor_id, optional: true
  belongs_to :session_refresh_method
  belongs_to :sdp_alines_filter_type, class_name: 'FilterType', foreign_key: :sdp_alines_filter_type_id
  belongs_to :orig_disconnect_policy, class_name: 'DisconnectPolicy', foreign_key: :orig_disconnect_policy_id, optional: true
  belongs_to :term_disconnect_policy, class_name: 'DisconnectPolicy', foreign_key: :term_disconnect_policy_id, optional: true
  belongs_to :gateway_group, optional: true
  belongs_to :pop, optional: true
  belongs_to :codec_group
  belongs_to :sdp_c_location, class_name: 'SdpCLocation'
  belongs_to :sensor, class_name: 'System::Sensor', foreign_key: :sensor_id, optional: true
  belongs_to :sensor_level, class_name: 'System::SensorLevel', foreign_key: :sensor_level_id
  belongs_to :dtmf_receive_mode, class_name: 'System::DtmfReceiveMode', foreign_key: :dtmf_receive_mode_id
  belongs_to :dtmf_send_mode, class_name: 'System::DtmfSendMode', foreign_key: :dtmf_send_mode_id
  belongs_to :radius_accounting_profile, class_name: 'Equipment::Radius::AccountingProfile', foreign_key: :radius_accounting_profile_id, optional: true
  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :term_proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :term_proxy_transport_protocol_id
  belongs_to :orig_proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :orig_proxy_transport_protocol_id
  belongs_to :rel100_mode, class_name: 'Equipment::GatewayRel100Mode', foreign_key: :rel100_mode_id
  belongs_to :rx_inband_dtmf_filtering_mode, class_name: 'Equipment::GatewayInbandDtmfFilteringMode', foreign_key: :rx_inband_dtmf_filtering_mode_id
  belongs_to :tx_inband_dtmf_filtering_mode, class_name: 'Equipment::GatewayInbandDtmfFilteringMode', foreign_key: :tx_inband_dtmf_filtering_mode_id
  belongs_to :network_protocol_priority, class_name: 'Equipment::GatewayNetworkProtocolPriority', foreign_key: :network_protocol_priority_id
  belongs_to :media_encryption_mode, class_name: 'Equipment::GatewayMediaEncryptionMode', foreign_key: :media_encryption_mode_id
  belongs_to :termination_dst_numberlist, class_name: 'Routing::Numberlist', foreign_key: :termination_dst_numberlist_id, optional: true
  belongs_to :termination_src_numberlist, class_name: 'Routing::Numberlist', foreign_key: :termination_src_numberlist_id, optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true
  belongs_to :diversion_send_mode, class_name: 'Equipment::GatewayDiversionSendMode', foreign_key: :diversion_send_mode_id
  belongs_to :stir_shaken_crt, class_name: 'Equipment::StirShaken::SigningCertificate', foreign_key: :stir_shaken_crt_id, optional: :true
  belongs_to :throttling_profile, class_name: 'Equipment::GatewayThrottlingProfile', foreign_key: :throttling_profile_id, optional: true
  belongs_to :scheduler, class_name: 'System::Scheduler', foreign_key: :scheduler_id, optional: true

  has_many :customers_auths, class_name: 'CustomersAuth', dependent: :restrict_with_error
  has_many :api_accesses, class_name: 'System::ApiAccess', foreign_key: :provision_gateway_id, dependent: :nullify
  has_many :dialpeers, class_name: 'Dialpeer', dependent: :restrict_with_error
  has_many :quality_stats, class_name: 'Stats::TerminationQualityStat', foreign_key: :gateway_id, dependent: :nullify
  has_many :rate_management_projects, class_name: 'RateManagement::Project'
  has_many :active_rate_management_pricelist_items,
           -> { not_applied },
           class_name: 'RateManagement::PricelistItem'
  has_many :applied_rate_management_pricelist_items,
           -> { applied },
           class_name: 'RateManagement::PricelistItem',
           dependent: :nullify
  has_one :statistic, class_name: 'GatewaysStat', dependent: :delete

  include WithPaperTrail

  validates :sdp_alines_filter_type, :codec_group, :sdp_c_location, :sensor_level_id, presence: true
  validates :dtmf_receive_mode, :dtmf_send_mode, :rel100_mode, presence: true
  validates :name, :priority, :weight, presence: true
  validates :name, uniqueness: true
  validates :enabled, :auth_enabled, inclusion: { in: [true, false] }

  validates :weight, :priority, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: false, only_integer: true }

  validates :session_refresh_method, presence: true
  validates :name, uniqueness: { allow_blank: false }

  validates :acd_limit, numericality: { greater_than_or_equal_to: 0.00 }
  validates :asr_limit, numericality: { greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00 }
  validates :short_calls_limit, numericality: { greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00 }

  validates :max_30x_redirects, :max_transfers, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }

  validates :origination_capacity,
            :termination_capacity,
            :termination_subscriber_capacity,
            :termination_cps_limit,
            :termination_subscriber_cps_limit,
            numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }

  validates :termination_cps_wsize,
            :termination_subscriber_cps_wsize,
            numericality: { greater_than: 0, less_than_or_equal_to: 900, allow_nil: false, only_integer: true }

  validates :port, numericality: { greater_than_or_equal_to: ApplicationRecord::L4_PORT_MIN, less_than_or_equal_to: ApplicationRecord::L4_PORT_MAX, allow_nil: true, only_integer: true }

  validates :fake_180_timer, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }
  validates :transport_protocol, :term_proxy_transport_protocol, :orig_proxy_transport_protocol,
                        :network_protocol_priority, :media_encryption_mode, :sdp_c_location, :sip_schema_id, presence: true

  validates :registered_aor_mode_id, inclusion: { in: REGISTERED_AOR_MODES.keys }, allow_nil: true

  validates :pai_send_mode_id, inclusion: { in: PAI_SEND_MODES.keys }, allow_nil: true
  validates :pai_domain,
            presence: true,
            if: proc {
              [
                PAI_SEND_MODE_BUILD_SIP, PAI_SEND_MODE_BUILD_SIP_WITH_USER_PHONE,
                PAI_SEND_MODE_RELAY_AS_SIP, PAI_SEND_MODE_RELAY_AS_SIP_FORCE_DOMAIN
              ].include?(pai_send_mode_id)
            }

  validates :diversion_domain, presence: true, if: proc { diversion_send_mode_id == 2 }

  validates :auth_user, :auth_password, format: { without: /\s/, message: 'must contain no spaces' }

  validates :incoming_auth_username, presence: true, if: proc { incoming_auth_password.present? }
  validates :incoming_auth_password, presence: true, if: proc { incoming_auth_username.present? }
  validates :incoming_auth_username, :incoming_auth_password, format: { without: /\s/, message: 'must contain no spaces' }

  validates :transit_headers_from_origination, :transit_headers_from_termination,
            format: { with: /\A[a-zA-Z\-\,\*]*\z/, message: 'Enter headers separated by comma. Header name can contain letters, * and -' }

  validates :stir_shaken_mode_id, inclusion: { in: STIR_SHAKEN_MODES.keys }, allow_nil: false
  validates :sip_schema_id, inclusion: { in: SIP_SCHEMAS.keys }, allow_nil: false
  validates :privacy_mode_id, inclusion: { in: PRIVACY_MODES.keys }, allow_nil: false

  validate :vendor_owners_the_gateway_group
  validate :vendor_can_be_changed
  validate :allow_termination_can_be_enabled
  validate :is_shared_can_be_changed
  validate :incoming_auth_can_be_disabled

  validates :rtp_timeout, presence: true
  validates :rtp_timeout, allow_blank: true, numericality: {
    greater_than_or_equal_to: RTP_TIMEOUT_MIN,
    less_than_or_equal_to: RTP_TIMEOUT_MAX,
    only_integer: true
  }

  validates :rtp_acl, array_format: { without: /\s/, message: 'spaces are not allowed', allow_nil: true }, array_uniqueness: { allow_nil: true }
  validate :validate_rtp_acl

  validates :dump_level_id, presence: true
  validates :dump_level_id, inclusion: { in: CustomersAuth::DUMP_LEVELS.keys }, allow_nil: false

  validates :orig_outbound_proxy, presence: true, if: proc { orig_use_outbound_proxy? or orig_force_outbound_proxy? }
  validates :term_outbound_proxy, presence: true, if: proc { term_use_outbound_proxy? or term_force_outbound_proxy? }

  include Yeti::ResourceStatus
  include Yeti::Scheduler

  scope :locked, -> { where locked: true }
  scope :with_radius_accounting, -> { where 'radius_accounting_profile_id is not null' }
  scope :with_dump, -> { where('dump_level_id > 0') }
  scope :shared, -> { where is_shared: true }
  scope :origination_contractor_id_eq, lambda { |contractor_id|
    where("#{table_name}.allow_origination AND (#{table_name}.is_shared OR #{table_name}.contractor_id=?)", contractor_id)
  }
  scope :termination_contractor_id_eq, lambda { |contractor_id|
    where("#{table_name}.allow_termination AND (#{table_name}.contractor_id=? OR #{table_name}.is_shared)", contractor_id)
  }
  scope :search_for, ->(term) { where("name || ' | ' || id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }

  before_validation do
    self.term_next_hop = nil if term_next_hop.blank?
    self.auth_from_user = nil if auth_from_user.blank?
    self.auth_from_domain = nil if auth_from_domain.blank?
  end

  before_validation :ensure_rtp_acl_format

  before_destroy :check_associated_records

  include PgEvent
  has_pg_queue 'gateway-sync'

  def transit_headers_from_origination=(s)
    if s.nil?
      self[:transit_headers_from_origination] = nil
    else
      self[:transit_headers_from_origination] = s.split(',').uniq.reject(&:blank?).join(',')
    end
  end

  def transit_headers_from_termination=(s)
    if s.nil?
      self[:transit_headers_from_termination]
    else
      self[:transit_headers_from_termination] = s.split(',').uniq.reject(&:blank?).join(',')
    end
  end

  def rtp_acl=(value)
    value = value.split(',').map(&:strip).reject(&:blank?) if value.is_a? String
    self[:rtp_acl] = value
  end

  def orig_append_headers_reply=(value)
    value = value.split("\r\n").map(&:strip).reject(&:blank?) if value.is_a? String
    self[:orig_append_headers_reply] = value
  end

  def orig_append_headers_req=(value)
    value = value.split("\r\n").map(&:strip).reject(&:blank?) if value.is_a? String
    self[:orig_append_headers_req] = value
  end

  def term_append_headers_req=(value)
    value = value.split("\r\n").map(&:strip).reject(&:blank?) if value.is_a? String
    self[:term_append_headers_req] = value
  end

  def transfer_append_headers_req=(value)
    value = value.split("\r\n").map(&:strip).reject(&:blank?) if value.is_a? String
    self[:transfer_append_headers_req] = value
  end

  def host=(value)
    self[:host] = self.class.normalize_host(value)
  end

  def display_name
    "#{name} | #{id}"
  end

  scope :originations, -> { where(allow_origination: true) }
  scope :terminations, -> { where(allow_termination: true) }

  scope :disabled_for_origination, lambda {
    where(
      Gateway.arel_table[:allow_origination].eq(false).or(Gateway.arel_table[:enabled].eq(false))
    )
  }
  scope :disabled_for_termination, lambda {
    where(
      Gateway.arel_table[:allow_termination].eq(false).or(Gateway.arel_table[:enabled].eq(false))
    )
  }

  def pai_send_mode_name
    PAI_SEND_MODES[pai_send_mode_id]
  end

  def registered_aor_mode_name
    REGISTERED_AOR_MODES[registered_aor_mode_id]
  end

  def stir_shaken_mode_name
    STIR_SHAKEN_MODES[stir_shaken_mode_id]
  end

  def sip_schema_name
    SIP_SCHEMAS[sip_schema_id]
  end

  def privacy_mode_name
    PRIVACY_MODES[privacy_mode_id]
  end

  def dump_level_name
    dump_level_id.nil? ? DUMP_LEVELS[0] : DUMP_LEVELS[dump_level_id]
  end

  def use_registered_aor?
    registered_aor_mode_id > 0
  end

  protected

  def allow_termination_can_be_enabled
    if host.blank? && registered_aor_mode_id == 0 && allow_termination == true
      errors.add(:allow_termination, I18n.t('activerecord.errors.models.gateway.attributes.allow_termination.empty_host_for_termination'))
      errors.add(:host, I18n.t('activerecord.errors.models.gateway.attributes.host.empty_host_for_termination'))
      errors.add(:registered_aor_mode_id, I18n.t('activerecord.errors.models.gateway.attributes.registered_aor_mode_id.empty_host_for_termination'))
    end
  end

  def vendor_owners_the_gateway_group
    errors.add(:gateway_group, I18n.t('activerecord.errors.models.gateway.attributes.gateway_group.wrong_owner')) unless gateway_group_id.nil? || (contractor_id && contractor_id == gateway_group.vendor_id)
  end

  def vendor_can_be_changed
    if contractor_id_changed?
      errors.add(:contractor, I18n.t('activerecord.errors.models.gateway.attributes.contractor.vendor_cant_be_changed')) if dialpeers.any?
    end
  end

  def is_shared_can_be_changed
    return true unless is_shared_changed?(from: true, to: false)

    if dialpeers.any?
      errors.add(:is_shared, I18n.t('activerecord.errors.models.gateway.attributes.contractor.cant_be_changed_when_linked_to_dialpeer'))
    end
    if customers_auths.any?
      errors.add(:is_shared, I18n.t('activerecord.errors.models.gateway.attributes.contractor.cant_be_changed_when_linked_to_customers_auth'))
    end
  end

  def incoming_auth_can_be_disabled
    if incoming_auth_disabled? && customers_auths.where(require_incoming_auth: true).any?
      errors.add(:incoming_auth_username, I18n.t('activerecord.errors.models.gateway.attributes.incoming_auth_username.cant_be_cleared'))
      errors.add(:incoming_auth_password, I18n.t('activerecord.errors.models.gateway.attributes.incoming_auth_password.cant_be_cleared'))
    end
  end

  include Yeti::StateUpdater
  self.state_names = %w[auth_credentials gateways_cache]

  private

  def validate_rtp_acl
    return unless rtp_acl.is_a?(Array)

    rtp_acl.each do |raw_ip|
      IPAddr.new(raw_ip)
    end
  rescue IPAddr::Error => _e
    errors.add(:rtp_acl, :invalid)
  end

  def ensure_rtp_acl_format
    self.rtp_acl = nil if rtp_acl.blank?
  end

  def incoming_auth_disabled?
    (
      (incoming_auth_username_changed?(to: nil) || incoming_auth_username_changed?(to: '')
      ) && incoming_auth_allow_jwt == false
    ) || (incoming_auth_allow_jwt_changed?(to: false) && incoming_auth_username == true)
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

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      search_for
      ordered_by
      origination_contractor_id_eq
      termination_contractor_id_eq
    ]
  end
end
