# frozen_string_literal: true

# == Schema Information
#
# Table name: gateways
#
#  id                               :integer          not null, primary key
#  host                             :string
#  port                             :integer
#  src_rewrite_rule                 :string
#  dst_rewrite_rule                 :string
#  acd_limit                        :float            default(0.0), not null
#  asr_limit                        :float            default(0.0), not null
#  enabled                          :boolean          not null
#  name                             :string           not null
#  auth_enabled                     :boolean          default(FALSE), not null
#  auth_user                        :string
#  auth_password                    :string
#  term_outbound_proxy              :string
#  term_next_hop_for_replies        :boolean          default(FALSE), not null
#  term_use_outbound_proxy          :boolean          default(FALSE), not null
#  contractor_id                    :integer          not null
#  allow_termination                :boolean          default(TRUE), not null
#  allow_origination                :boolean          default(TRUE), not null
#  anonymize_sdp                    :boolean          default(TRUE), not null
#  proxy_media                      :boolean          default(TRUE), not null
#  transparent_seqno                :boolean          default(FALSE), not null
#  transparent_ssrc                 :boolean          default(FALSE), not null
#  sst_enabled                      :boolean          default(FALSE)
#  sst_minimum_timer                :integer          default(50), not null
#  sst_maximum_timer                :integer          default(50), not null
#  sst_accept501                    :boolean          default(TRUE), not null
#  session_refresh_method_id        :integer          default(3), not null
#  sst_session_expires              :integer          default(50)
#  term_force_outbound_proxy        :boolean          default(FALSE), not null
#  locked                           :boolean          default(FALSE), not null
#  codecs_payload_order             :string           default("")
#  codecs_prefer_transcoding_for    :string           default("")
#  src_rewrite_result               :string
#  dst_rewrite_result               :string
#  termination_capacity             :integer
#  term_next_hop                    :string
#  orig_next_hop                    :string
#  orig_append_headers_req          :string
#  term_append_headers_req          :string
#  dialog_nat_handling              :boolean          default(TRUE), not null
#  orig_force_outbound_proxy        :boolean          default(FALSE), not null
#  orig_use_outbound_proxy          :boolean          default(FALSE), not null
#  orig_outbound_proxy              :string
#  prefer_existing_codecs           :boolean          default(TRUE), not null
#  force_symmetric_rtp              :boolean          default(TRUE), not null
#  transparent_dialog_id            :boolean          default(FALSE), not null
#  sdp_alines_filter_type_id        :integer          default(0), not null
#  sdp_alines_filter_list           :string
#  gateway_group_id                 :integer
#  orig_disconnect_policy_id        :integer
#  term_disconnect_policy_id        :integer
#  diversion_policy_id              :integer          default(1), not null
#  diversion_rewrite_rule           :string
#  diversion_rewrite_result         :string
#  src_name_rewrite_rule            :string
#  src_name_rewrite_result          :string
#  priority                         :integer          default(100), not null
#  pop_id                           :integer
#  codec_group_id                   :integer          default(1), not null
#  single_codec_in_200ok            :boolean          default(FALSE), not null
#  ringing_timeout                  :integer
#  symmetric_rtp_nonstop            :boolean          default(FALSE), not null
#  symmetric_rtp_ignore_rtcp        :boolean          default(FALSE), not null
#  resolve_ruri                     :boolean          default(FALSE), not null
#  force_dtmf_relay                 :boolean          default(FALSE), not null
#  relay_options                    :boolean          default(FALSE), not null
#  rtp_ping                         :boolean          default(FALSE), not null
#  filter_noaudio_streams           :boolean          default(FALSE), not null
#  relay_reinvite                   :boolean          default(FALSE), not null
#  sdp_c_location_id                :integer          default(2), not null
#  auth_from_user                   :string
#  auth_from_domain                 :string
#  relay_hold                       :boolean          default(FALSE), not null
#  rtp_timeout                      :integer          default(30), not null
#  relay_prack                      :boolean          default(FALSE), not null
#  rtp_relay_timestamp_aligning     :boolean          default(FALSE), not null
#  allow_1xx_without_to_tag         :boolean          default(FALSE), not null
#  sip_timer_b                      :integer          default(8000), not null
#  dns_srv_failover_timer           :integer          default(2000), not null
#  rtp_force_relay_cn               :boolean          default(TRUE), not null
#  sensor_id                        :integer
#  sensor_level_id                  :integer          default(1), not null
#  dtmf_send_mode_id                :integer          default(1), not null
#  dtmf_receive_mode_id             :integer          default(1), not null
#  relay_update                     :boolean          default(FALSE), not null
#  suppress_early_media             :boolean          default(FALSE), not null
#  send_lnp_information             :boolean          default(FALSE), not null
#  short_calls_limit                :float            default(1.0), not null
#  origination_capacity             :integer
#  force_one_way_early_media        :boolean          default(FALSE), not null
#  radius_accounting_profile_id     :integer
#  transit_headers_from_origination :string
#  transit_headers_from_termination :string
#  external_id                      :integer
#  fake_180_timer                   :integer
#  sip_interface_name               :string
#  rtp_interface_name               :string
#  transport_protocol_id            :integer          default(1), not null
#  term_proxy_transport_protocol_id :integer          default(1), not null
#  orig_proxy_transport_protocol_id :integer          default(1), not null
#  rel100_mode_id                   :integer          default(4), not null
#  is_shared                        :boolean          default(FALSE), not null
#  max_30x_redirects                :integer          default(0), not null
#  max_transfers                    :integer          default(0), not null
#  incoming_auth_username           :string
#  incoming_auth_password           :string
#  rx_inband_dtmf_filtering_mode_id :integer          default(1), not null
#  tx_inband_dtmf_filtering_mode_id :integer          default(1), not null
#  weight                           :integer          default(100), not null
#  sip_schema_id                    :integer          default(1), not null
#  network_protocol_priority_id     :integer          default(0), not null
#  media_encryption_mode_id         :integer          default(0), not null
#  preserve_anonymous_from_domain   :boolean          default(FALSE), not null
#  termination_src_numberlist_id    :integer
#  termination_dst_numberlist_id    :integer
#  lua_script_id                    :integer
#  use_registered_aor               :boolean          default(FALSE), not null
#

require 'resolv'
class Gateway < Yeti::ActiveRecord
  belongs_to :contractor
  belongs_to :vendor, -> { vendors }, class_name: 'Contractor', foreign_key: :contractor_id
  belongs_to :session_refresh_method
  belongs_to :sdp_alines_filter_type, class_name: 'FilterType', foreign_key: :sdp_alines_filter_type_id
  belongs_to :orig_disconnect_policy, class_name: 'DisconnectPolicy', foreign_key: :orig_disconnect_policy_id
  belongs_to :term_disconnect_policy, class_name: 'DisconnectPolicy', foreign_key: :term_disconnect_policy_id
  belongs_to :gateway_group
  belongs_to :diversion_policy
  belongs_to :pop
  belongs_to :codec_group
  belongs_to :sdp_c_location, class_name: 'SdpCLocation'
  belongs_to :sensor, class_name: 'System::Sensor', foreign_key: :sensor_id
  belongs_to :sensor_level, class_name: 'System::SensorLevel', foreign_key: :sensor_level_id
  belongs_to :dtmf_receive_mode, class_name: 'System::DtmfReceiveMode', foreign_key: :dtmf_receive_mode_id
  belongs_to :dtmf_send_mode, class_name: 'System::DtmfSendMode', foreign_key: :dtmf_send_mode_id
  belongs_to :radius_accounting_profile, class_name: 'Equipment::Radius::AccountingProfile', foreign_key: :radius_accounting_profile_id
  belongs_to :transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :transport_protocol_id
  belongs_to :term_proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :term_proxy_transport_protocol_id
  belongs_to :orig_proxy_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :orig_proxy_transport_protocol_id
  belongs_to :rel100_mode, class_name: 'Equipment::GatewayRel100Mode', foreign_key: :rel100_mode_id
  belongs_to :rx_inband_dtmf_filtering_mode, class_name: 'Equipment::GatewayInbandDtmfFilteringMode', foreign_key: :rx_inband_dtmf_filtering_mode_id
  belongs_to :tx_inband_dtmf_filtering_mode, class_name: 'Equipment::GatewayInbandDtmfFilteringMode', foreign_key: :tx_inband_dtmf_filtering_mode_id
  belongs_to :network_protocol_priority, class_name: 'Equipment::GatewayNetworkProtocolPriority', foreign_key: :network_protocol_priority_id
  belongs_to :media_encryption_mode, class_name: 'Equipment::GatewayMediaEncryptionMode', foreign_key: :media_encryption_mode_id
  belongs_to :sip_schema, class_name: 'System::SipSchema', foreign_key: :sip_schema_id
  belongs_to :termination_dst_numberlist, class_name: 'Routing::Numberlist', foreign_key: :termination_dst_numberlist_id
  belongs_to :termination_src_numberlist, class_name: 'Routing::Numberlist', foreign_key: :termination_src_numberlist_id
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id

  has_many :customers_auths, class_name: 'CustomersAuth', dependent: :restrict_with_error
  has_many :dialpeers, class_name: 'Dialpeer', dependent: :restrict_with_error
  has_many :quality_stats, class_name: 'Stats::TerminationQualityStat', foreign_key: :gateway_id, dependent: :nullify
  has_one :statistic, class_name: 'GatewaysStat', dependent: :delete

  has_paper_trail class_name: 'AuditLogItem'

  validates_presence_of :contractor, :sdp_alines_filter_type, :codec_group, :sdp_c_location, :sensor_level_id
  validates_presence_of :dtmf_receive_mode, :dtmf_send_mode, :rel100_mode
  validates_presence_of :name, :priority, :weight
  validates_uniqueness_of :name
  validates :enabled, :auth_enabled, inclusion: { in: [true, false] }

  validates_numericality_of :weight, :priority, greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: false, only_integer: true

  validates_presence_of :session_refresh_method
  validates_uniqueness_of :name, allow_blank: false

  validates_numericality_of :acd_limit, greater_than_or_equal_to: 0.00
  validates_numericality_of :asr_limit, greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00
  validates_numericality_of :short_calls_limit, greater_than_or_equal_to: 0.00, less_than_or_equal_to: 1.00

  validates_numericality_of :max_30x_redirects, :max_transfers, greater_than_or_equal_to: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true

  validates_numericality_of :origination_capacity, :termination_capacity, greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true
  validates_numericality_of :port, greater_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MIN, less_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MAX, allow_nil: true, only_integer: true

  validates_numericality_of :fake_180_timer, greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true
  validates_presence_of :transport_protocol, :term_proxy_transport_protocol, :orig_proxy_transport_protocol,
                        :network_protocol_priority, :media_encryption_mode, :sdp_c_location, :sip_schema

  validates :incoming_auth_username, presence: true, if: proc { incoming_auth_password.present? }
  validates :incoming_auth_password, presence: true, if: proc { incoming_auth_username.present? }

  validates :transit_headers_from_origination, :transit_headers_from_termination,
            format: { with: /\A[a-zA-Z\-\,\*]*\z/, message: 'Enter headers separated by comma. Header name can contain letters, * and -' }

  validate :vendor_owners_the_gateway_group
  validate :vendor_can_be_changed
  validate :allow_termination_can_be_enabled
  validate :is_shared_can_be_changed
  validate :incoming_auth_can_be_disabled

  include Yeti::ResourceStatus

  scope :locked, -> { where locked: true }
  scope :with_radius_accounting, -> { where 'radius_accounting_profile_id is not null' }
  scope :shared, -> { where is_shared: true }
  scope :for_origination, ->(contractor_id) { where('allow_origination and ( is_shared or contractor_id=?)', contractor_id).order(:name) }
  scope :search_for, ->(term) { where("name || ' | ' || id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }
  scope :for_termination, lambda { |contractor_id|
    where("#{table_name}.allow_termination AND (#{table_name}.contractor_id=? OR #{table_name}.is_shared)", contractor_id)
      .joins(:vendor)
      .order(:name)
  }

  before_validation do
    self.term_next_hop = nil if term_next_hop.blank?
    self.auth_from_user = nil if auth_from_user.blank?
    self.auth_from_domain = nil if auth_from_domain.blank?
  end

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

  def fire_lock(stat)
    transaction do
      self.locked = true
      save
      Notification::Alert.fire_lock(self, stat)
    end
  end

  def unlock
    transaction do
      self.locked = false
      save
      Notification::Alert.fire_unlock(self)
    end
  end

  protected

  def allow_termination_can_be_enabled
    if host.blank? && use_registered_aor == false && (allow_termination == true)
      errors.add(:allow_termination, I18n.t('activerecord.errors.models.gateway.attributes.allow_termination.empty_host_for_termination'))
      errors.add(:host, I18n.t('activerecord.errors.models.gateway.attributes.host.empty_host_for_termination'))
      errors.add(:use_registered_aor, I18n.t('activerecord.errors.models.gateway.attributes.use_registered_aor.empty_host_for_termination'))
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
    if (incoming_auth_username_changed?(to: nil) || incoming_auth_username_changed?(to: '')) && customers_auths.where(require_incoming_auth: true).any?
      errors.add(:incoming_auth_username, I18n.t('activerecord.errors.models.gateway.attributes.incoming_auth_username.cant_be_cleared'))
      errors.add(:incoming_auth_password, I18n.t('activerecord.errors.models.gateway.attributes.incoming_auth_password.cant_be_cleared'))
    end
  end

  include Yeti::IncomingAuthReloader

  private

  # @see Yeti::IncomingAuthReloader
  def reload_incoming_auth_on_create?
    incoming_auth_username.present?
  end

  # @see Yeti::IncomingAuthReloader
  def reload_incoming_auth_on_update?
    (incoming_auth_username.present? && enabled_changed?) || incoming_auth_changed?
  end

  # @see Yeti::IncomingAuthReloader
  def reload_incoming_auth_on_destroy?
    incoming_auth_username.present?
  end

  def incoming_auth_changed?
    incoming_auth_username_changed? || incoming_auth_password_changed?
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      search_for ordered_by
    ]
  end
end
