# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr.cdr
#
#  id                              :bigint(8)        not null, primary key
#  audio_recorded                  :boolean
#  auth_orig_ip                    :inet
#  auth_orig_port                  :integer(4)
#  core_version                    :string
#  customer_acc_vat                :decimal(, )
#  customer_account_check_balance  :boolean
#  customer_auth_name              :string
#  customer_duration               :integer(4)
#  customer_price                  :decimal(, )
#  customer_price_no_vat           :decimal(, )
#  destination_fee                 :decimal(, )
#  destination_initial_interval    :integer(4)
#  destination_initial_rate        :decimal(, )
#  destination_next_interval       :integer(4)
#  destination_next_rate           :decimal(, )
#  destination_prefix              :string
#  destination_reverse_billing     :boolean
#  dialpeer_fee                    :decimal(, )
#  dialpeer_initial_interval       :integer(4)
#  dialpeer_initial_rate           :decimal(, )
#  dialpeer_next_interval          :integer(4)
#  dialpeer_next_rate              :decimal(, )
#  dialpeer_prefix                 :string
#  dialpeer_reverse_billing        :boolean
#  diversion_in                    :string
#  diversion_out                   :string
#  dst_prefix_in                   :string
#  dst_prefix_out                  :string
#  dst_prefix_routing              :string
#  duration                        :integer(4)
#  early_media_present             :boolean
#  from_domain                     :string
#  global_tag                      :string
#  internal_disconnect_code        :integer(4)
#  internal_disconnect_reason      :string
#  is_last_cdr                     :boolean
#  is_redirected                   :boolean
#  lega_disconnect_code            :integer(4)
#  lega_disconnect_reason          :string
#  lega_identity                   :jsonb
#  lega_user_agent                 :string
#  legb_disconnect_code            :integer(4)
#  legb_disconnect_reason          :string
#  legb_local_tag                  :string
#  legb_outbound_proxy             :string
#  legb_ruri                       :string
#  legb_user_agent                 :string
#  local_tag                       :string
#  lrn                             :string
#  p_charge_info_in                :string
#  pai_in                          :string
#  pai_out                         :string
#  pdd                             :float
#  ppi_in                          :string
#  ppi_out                         :string
#  privacy_in                      :string
#  privacy_out                     :string
#  profit                          :decimal(, )
#  routing_attempt                 :integer(4)
#  routing_delay                   :float
#  routing_tag_ids                 :integer(2)       is an Array
#  rpid_in                         :string
#  rpid_out                        :string
#  rpid_privacy_in                 :string
#  rpid_privacy_out                :string
#  rtt                             :float
#  ruri_domain                     :string
#  sign_orig_ip                    :string
#  sign_orig_local_ip              :string
#  sign_orig_local_port            :integer(4)
#  sign_orig_port                  :integer(4)
#  sign_term_ip                    :string
#  sign_term_local_ip              :string
#  sign_term_local_port            :integer(4)
#  sign_term_port                  :integer(4)
#  src_name_in                     :string
#  src_name_out                    :string
#  src_prefix_in                   :string
#  src_prefix_out                  :string
#  src_prefix_routing              :string
#  success                         :boolean
#  time_connect                    :datetime
#  time_end                        :datetime
#  time_limit                      :string
#  time_start                      :datetime         not null
#  to_domain                       :string
#  uuid                            :uuid
#  vendor_duration                 :integer(4)
#  vendor_price                    :decimal(, )
#  yeti_version                    :string
#  auth_orig_transport_protocol_id :integer(2)
#  customer_acc_external_id        :bigint(8)
#  customer_acc_id                 :integer(4)
#  customer_auth_external_id       :bigint(8)
#  customer_auth_id                :integer(4)
#  customer_external_id            :bigint(8)
#  customer_id                     :integer(4)
#  customer_invoice_id             :integer(4)
#  destination_id                  :integer(4)
#  destination_rate_policy_id      :integer(4)
#  dialpeer_id                     :integer(4)
#  disconnect_initiator_id         :integer(4)
#  dst_area_id                     :integer(4)
#  dst_country_id                  :integer(4)
#  dst_network_id                  :integer(4)
#  dump_level_id                   :integer(2)
#  failed_resource_id              :bigint(8)
#  failed_resource_type_id         :integer(2)
#  lega_identity_attestation_id    :integer(2)
#  lega_identity_verstat_id        :integer(2)
#  lnp_database_id                 :integer(2)
#  node_id                         :integer(4)
#  orig_call_id                    :string
#  orig_gw_external_id             :bigint(8)
#  orig_gw_id                      :integer(4)
#  pop_id                          :integer(4)
#  rateplan_id                     :integer(4)
#  routing_group_id                :integer(4)
#  routing_plan_id                 :integer(4)
#  sign_orig_transport_protocol_id :integer(2)
#  sign_term_transport_protocol_id :integer(2)
#  src_area_id                     :integer(4)
#  src_country_id                  :integer(4)
#  src_network_id                  :integer(4)
#  term_call_id                    :string
#  term_gw_external_id             :bigint(8)
#  term_gw_id                      :integer(4)
#  vendor_acc_external_id          :bigint(8)
#  vendor_acc_id                   :integer(4)
#  vendor_external_id              :bigint(8)
#  vendor_id                       :integer(4)
#  vendor_invoice_id               :integer(4)
#
# Indexes
#
#  cdr_customer_acc_external_id_time_start_idx  (customer_acc_external_id,time_start) WHERE is_last_cdr
#  cdr_customer_acc_id_time_start_idx           (customer_acc_id,time_start) WHERE is_last_cdr
#  cdr_customer_acc_id_time_start_idx1          (customer_acc_id,time_start)
#  cdr_customer_invoice_id_idx                  (customer_invoice_id)
#  cdr_id_idx                                   (id)
#  cdr_time_start_idx                           (time_start)
#  cdr_vendor_invoice_id_idx                    (vendor_invoice_id)
#

class Cdr::Cdr < Cdr::Base
  self.table_name = 'cdr.cdr'
  self.primary_key = :id

  DUMP_LEVEL_NO = 0
  DUMP_LEVEL_SIP = 1
  DUMP_LEVEL_RTP = 2
  DUMP_LEVEL_ALL = 3
  DUMP_LEVELS = {
    DUMP_LEVEL_NO => 'None',
    DUMP_LEVEL_SIP => 'SIP',
    DUMP_LEVEL_RTP => 'RTP',
    DUMP_LEVEL_ALL => 'Full'
  }.freeze

  DISCONNECT_INITIATOR_ROUTING = 0
  DISCONNECT_INITIATOR_SWITCH = 1
  DISCONNECT_INITIATOR_DEST = 2
  DISCONNECT_INITIATOR_ORIG = 3

  DISCONNECT_INITIATORS = {
    DISCONNECT_INITIATOR_ROUTING => 'Routing',
    DISCONNECT_INITIATOR_SWITCH => 'Switch',
    DISCONNECT_INITIATOR_DEST => 'Destination',
    DISCONNECT_INITIATOR_ORIG => 'Origination'
  }.freeze

  ADMIN_PRELOAD_LIST = %i[
    dialpeer routing_group destination
    auth_orig_transport_protocol sign_orig_transport_protocol
    src_network src_country
    dst_network dst_country
    routing_plan vendor
    term_gw orig_gw customer_auth vendor_acc customer_acc
    dst_area customer rateplan pop src_area lnp_database
    node sign_term_transport_protocol
  ].freeze

  include Partitionable
  self.pg_partition_name = 'PgPartition::Cdr'
  self.pg_partition_interval_type = PgPartition::INTERVAL_DAY
  self.pg_partition_depth_past = 3
  self.pg_partition_depth_future = 3

  belongs_to :rateplan, class_name: 'Routing::Rateplan', foreign_key: :rateplan_id, optional: true
  belongs_to :routing_group, optional: true
  belongs_to :src_area, class_name: 'Routing::Area', foreign_key: :src_area_id, optional: true
  belongs_to :dst_area, class_name: 'Routing::Area', foreign_key: :dst_area_id, optional: true
  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan', foreign_key: :routing_plan_id, optional: true
  belongs_to :orig_gw, class_name: 'Gateway', foreign_key: :orig_gw_id, optional: true
  belongs_to :term_gw, class_name: 'Gateway', foreign_key: :term_gw_id, optional: true
  belongs_to :destination, class_name: 'Routing::Destination', optional: true
  belongs_to :dialpeer, optional: true
  belongs_to :customer_auth, class_name: 'CustomersAuth', foreign_key: :customer_auth_id, optional: true
  belongs_to :vendor_acc, class_name: 'Account', foreign_key: :vendor_acc_id, optional: true
  belongs_to :customer_acc, class_name: 'Account', foreign_key: :customer_acc_id, optional: true
  belongs_to :vendor, class_name: 'Contractor', foreign_key: :vendor_id, optional: true # ,:conditions => {:vendor => true}
  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id, optional: true # ,  :conditions => {:customer => true}
  belongs_to :vendor_invoice, class_name: 'Billing::Invoice', foreign_key: :vendor_invoice_id, optional: true
  belongs_to :customer_invoice, class_name: 'Billing::Invoice', foreign_key: :customer_invoice_id, optional: true
  belongs_to :node, class_name: 'Node', foreign_key: :node_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id, optional: true
  belongs_to :src_network, class_name: 'System::Network', foreign_key: :src_network_id, optional: true
  belongs_to :src_country, class_name: 'System::Country', foreign_key: :src_country_id, optional: true
  belongs_to :dst_network, class_name: 'System::Network', foreign_key: :dst_network_id, optional: true
  belongs_to :dst_country, class_name: 'System::Country', foreign_key: :dst_country_id, optional: true
  belongs_to :lnp_database, class_name: 'Lnp::Database', foreign_key: :lnp_database_id, optional: true
  belongs_to :auth_orig_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :auth_orig_transport_protocol_id, optional: true
  belongs_to :sign_orig_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :sign_orig_transport_protocol_id, optional: true
  belongs_to :sign_term_transport_protocol, class_name: 'Equipment::TransportProtocol', foreign_key: :sign_term_transport_protocol_id, optional: true

  scope :success, -> { where success: true }
  scope :failure, -> { where success: false }
  scope :routing_tag_ids_include, lambda { |id|
    where('? = ANY(routing_tag_ids)', id)
  }
  scope :routing_tag_ids_exclude, lambda { |id|
    where.not('? = ANY(routing_tag_ids)', id)
  }
  scope :routing_tag_ids_empty, lambda { |flag = true|
    if ActiveModel::Type::Boolean.new.cast(flag)
      where('routing_tag_ids IS NULL OR routing_tag_ids = \'{}\'')
    else
      where.not('routing_tag_ids IS NULL OR routing_tag_ids = \'{}\'')
    end
  }

  ##### metasearch override filters ##########

  scope :disconnect_code_eq, ->(code) { where('disconnect_code = ?', code) }
  # scope :vendor_acc_id_contains, lambda {|vendor_acc_id|where('vendor_acc_id = ?',vendor_acc_id )  }
  # scope :customer_acc_id_contains, lambda {|customer_acc_id|where('customer_acc_id = ?',customer_acc_id )  }

  scope :short_calls, -> { where('success AND duration<=?', GuiConfig.short_call_length) }
  scope :successful_calls, -> { where('success') }
  scope :rerouted_calls, -> { where('(NOT is_last_cdr) OR routing_attempt>1') }
  scope :not_authorized, -> { where('customer_auth_id is null') }
  scope :bad_routing, -> { where('customer_auth_id is not null AND disconnect_initiator_id=0') }
  scope :with_trace, -> { where('dump_level_id > 0') }

  scope :account_id_eq, ->(account_id) { where('vendor_acc_id =? OR customer_acc_id =?', account_id, account_id) }

  scope :where_customer, ->(id) { where(customer_id: id) }
  scope :where_account, ->(id) { where(customer_acc_id: id) } # OR vendor_acc_id ???

  scope :status_eq, lambda { |success|
    if success.is_a?(String)
      success = begin
                  success.to_bool
                rescue StandardError
                  nil
                end
    end

    where('success = ?', success) if [true, false].include? success
  }

  scope :auth_orig_ip_covers, lambda { |ip|
    begin
      IPAddr.new(ip)
    rescue StandardError
      return none
    end
    # auth_orig_ip contained by or equal to IP from filter
    where('auth_orig_ip<<=?::inet', ip)
  }

  #### end override filters ##############

  def status_sym
    success ? :success : :failure
  end

  def display_name
    id.to_s
  end

  def destination_rate_policy_name
    destination_rate_policy_id.nil? ? nil : Routing::DestinationRatePolicy::POLICIES[destination_rate_policy_id]
  end

  def disconnect_initiator_name
    disconnect_initiator_id.nil? ? nil : DISCONNECT_INITIATORS[disconnect_initiator_id]
  end

  def has_dump?
    !dump_level_id.nil? and dump_level_id > 0
  end

  def dump_level_name
    dump_level_id.nil? ? DUMP_LEVELS[0] : DUMP_LEVELS[dump_level_id]
  end

  def dump_filename
    if local_tag.present? && node_id.present?
      "/dump/#{local_tag}_#{node_id}.pcap"
    end
  end

  def call_record_filename_lega
    "/record/#{local_tag}_legA.mp3" if local_tag.present? && node_id.present?
  end

  def call_record_filename_legb
    "/record/#{local_tag}_legB.mp3" if local_tag.present? && node_id.present?
  end

  def attempts
    if local_tag.blank?
      self.class.where('cdr.id=?', id)
    else
      self.class.where(time_start: time_start).where(local_tag: local_tag).order('routing_attempt desc')
    end
  end

  def self.scoped_stat
    select("
    count(nullif(is_last_cdr,false)) as originated_calls_count,
    count(nullif(routing_attempt=2,false)) as rerouted_calls_count,
    100*count(nullif(routing_attempt=2,false))::real/nullif(count(nullif(is_last_cdr,false)),0)::real as rerouted_calls_percent,
    count(id) as termination_attempts_count,
    coalesce(sum(duration),0) as calls_duration,
    sum(duration)::float/nullif(count(nullif(success,false)),0)::float as ACD,
    count(nullif(success,false))::float/nullif(count(nullif(is_last_cdr,false)),0)::float as origination_asr,
    count(nullif(success,false))::float/nullif(count(id),0)::float as termination_asr,
    sum(profit) as profit,
    sum(customer_price) as customer_price,
    sum(vendor_price) as vendor_price").to_a[0]
  end

  def self.provisioning_info
    OpenStruct.new(
      new_events: new_events,
      pending_events: pending_events
    )
  end

  def self.new_events
    SqlCaller::Cdr.select_value("select ev_new from pgq.get_queue_info('cdr_billing')")
  end

  def self.pending_events
    SqlCaller::Cdr.select_value("select pending_events from pgq.get_consumer_info('cdr_billing', 'cdr_billing')")
  end

  scope :routing_tag_ids_array_contains, ->(*tag_id) { where.contains routing_tag_ids: Array(tag_id) }

  scope :tagged, lambda { |value|
    if ActiveModel::Type::Boolean.new.cast(value)
      where("routing_tag_ids <> '{}'") # has tags
    else
      where("routing_tag_ids = '{}' OR routing_tag_ids IS NULL") # no tags
    end
  }

  private

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      disconnect_code_eq
      status_eq
      account_id_eq
      routing_tag_ids_include
      routing_tag_ids_exclude
      routing_tag_ids_empty
      routing_tag_ids_array_contains
      tagged
      auth_orig_ip_covers
    ]
  end
end
