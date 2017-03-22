# == Schema Information
#
# Table name: cdr.cdr
#
#  id                           :integer          not null, primary key
#  customer_id                  :integer
#  vendor_id                    :integer
#  customer_acc_id              :integer
#  vendor_acc_id                :integer
#  customer_auth_id             :integer
#  destination_id               :integer
#  dialpeer_id                  :integer
#  orig_gw_id                   :integer
#  term_gw_id                   :integer
#  routing_group_id             :integer
#  rateplan_id                  :integer
#  destination_next_rate        :decimal(, )
#  destination_fee              :decimal(, )
#  dialpeer_next_rate           :decimal(, )
#  dialpeer_fee                 :decimal(, )
#  time_limit                   :string
#  internal_disconnect_code     :integer
#  internal_disconnect_reason   :string
#  disconnect_initiator_id      :integer
#  customer_price               :decimal(, )
#  vendor_price                 :decimal(, )
#  duration                     :integer
#  success                      :boolean
#  profit                       :decimal(, )
#  dst_prefix_in                :string
#  dst_prefix_out               :string
#  src_prefix_in                :string
#  src_prefix_out               :string
#  time_start                   :datetime
#  time_connect                 :datetime
#  time_end                     :datetime
#  sign_orig_ip                 :string
#  sign_orig_port               :integer
#  sign_orig_local_ip           :string
#  sign_orig_local_port         :integer
#  sign_term_ip                 :string
#  sign_term_port               :integer
#  sign_term_local_ip           :string
#  sign_term_local_port         :integer
#  orig_call_id                 :string
#  term_call_id                 :string
#  vendor_invoice_id            :integer
#  customer_invoice_id          :integer
#  local_tag                    :string
#  destination_initial_rate     :decimal(, )
#  dialpeer_initial_rate        :decimal(, )
#  destination_initial_interval :integer
#  destination_next_interval    :integer
#  dialpeer_initial_interval    :integer
#  dialpeer_next_interval       :integer
#  destination_rate_policy_id   :integer
#  routing_attempt              :integer
#  is_last_cdr                  :boolean
#  lega_disconnect_code         :integer
#  lega_disconnect_reason       :string
#  pop_id                       :integer
#  node_id                      :integer
#  src_name_in                  :string
#  src_name_out                 :string
#  diversion_in                 :string
#  diversion_out                :string
#  lega_rx_payloads             :string
#  lega_tx_payloads             :string
#  legb_rx_payloads             :string
#  legb_tx_payloads             :string
#  legb_disconnect_code         :integer
#  legb_disconnect_reason       :string
#  dump_level_id                :integer          default(0), not null
#  auth_orig_ip                 :inet
#  auth_orig_port               :integer
#  lega_rx_bytes                :integer
#  lega_tx_bytes                :integer
#  legb_rx_bytes                :integer
#  legb_tx_bytes                :integer
#  global_tag                   :string
#  dst_country_id               :integer
#  dst_network_id               :integer
#  lega_rx_decode_errs          :integer
#  lega_rx_no_buf_errs          :integer
#  lega_rx_parse_errs           :integer
#  legb_rx_decode_errs          :integer
#  legb_rx_no_buf_errs          :integer
#  legb_rx_parse_errs           :integer
#  src_prefix_routing           :string
#  dst_prefix_routing           :string
#  routing_plan_id              :integer
#  routing_delay                :float
#  pdd                          :float
#  rtt                          :float
#  early_media_present          :boolean
#  lnp_database_id              :integer
#  lrn                          :string
#  destination_prefix           :string
#  dialpeer_prefix              :string
#  audio_recorded               :boolean
#  ruri_domain                  :string
#  to_domain                    :string
#  from_domain                  :string
#

class Cdr::Cdr < Cdr::Base

  self.table_name = 'cdr.cdr'

  belongs_to :rateplan
  belongs_to :routing_group
  belongs_to :routing_tag, class_name: Routing::RoutingTag, foreign_key: :routing_tag_id
  belongs_to :src_area, class_name: Routing::Area, foreign_key: :src_area_id
  belongs_to :dst_area, class_name: Routing::Area, foreign_key: :dst_area_id
  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan', foreign_key: :routing_plan_id
  belongs_to :orig_gw, class_name: 'Gateway', foreign_key: :orig_gw_id
  belongs_to :term_gw, class_name: 'Gateway', foreign_key: :term_gw_id
  belongs_to :destination
  belongs_to :dialpeer
  belongs_to :destination_rate_policy
  belongs_to :customer_auth, class_name: 'CustomersAuth', foreign_key: :customer_auth_id
  belongs_to :vendor_acc, class_name: 'Account', foreign_key: :vendor_acc_id
  belongs_to :customer_acc, class_name: 'Account', foreign_key: :customer_acc_id
  belongs_to :vendor, class_name: 'Contractor', foreign_key: :vendor_id # ,:conditions => {:vendor => true}
  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id # ,  :conditions => {:customer => true}
  belongs_to :disconnect_initiator
  belongs_to :vendor_invoice, class_name: 'Billing::Invoice', foreign_key: :vendor_invoice_id
  belongs_to :customer_invoice, class_name: 'Billing::Invoice', foreign_key: :customer_invoice_id
  belongs_to :destination_rate_policy, class_name: 'DestinationRatePolicy', foreign_key: :destination_rate_policy_id
  belongs_to :node, class_name: 'Node', foreign_key: :node_id
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id
  belongs_to :dump_level
  belongs_to :dst_network, class_name: 'System::Network', foreign_key: :dst_network_id
  belongs_to :dst_country, class_name: 'System::Country', foreign_key: :dst_country_id
  belongs_to :lnp_database, class_name: Lnp::Database, foreign_key: :lnp_database_id
  belongs_to :auth_orig_transport_protocol, class_name: Equipment::TransportProtocol, foreign_key: :auth_orig_transport_protocol_id
  belongs_to :sign_orig_transport_protocol, class_name: Equipment::TransportProtocol, foreign_key: :sign_orig_transport_protocol_id
  belongs_to :sign_term_transport_protocol, class_name: Equipment::TransportProtocol, foreign_key: :sign_term_transport_protocol_id

  scope :success, -> { where success: true }
  scope :failure, -> { where success: false }

  DISCONNECTORS = DisconnectInitiator.all.index_by(&:id)





  ##### metasearch override filters ##########


  scope :disconnect_code_eq, lambda { |code| where('disconnect_code = ?', code) }
  #scope :vendor_acc_id_contains, lambda {|vendor_acc_id|where('vendor_acc_id = ?',vendor_acc_id )  }
  #scope :customer_acc_id_contains, lambda {|customer_acc_id|where('customer_acc_id = ?',customer_acc_id )  }

  scope :short_calls, -> { where('success AND duration<=?',GuiConfig.short_call_length) }
  scope :successful_calls, -> { where('success') }
  scope :rerouted_calls, -> { where('(NOT is_last_cdr) OR routing_attempt>1') }
  scope :no_rtp, -> { where('success AND (lega_tx_bytes=0 OR lega_rx_bytes=0 OR legb_tx_bytes=0 OR legb_rx_bytes=0)') }
  scope :not_authorized,  -> { where('customer_auth_id is null') }
  scope :bad_routing, -> { where('customer_auth_id is not null AND disconnect_initiator_id=0') }

  scope :account_id_eq, lambda { |account_id| where('vendor_acc_id =? OR customer_acc_id =?', account_id, account_id) }


  scope :status_eq, lambda { |success|
    if success.is_a?(String)
      success = success.to_bool rescue nil
    end

    where('success = ?', success) if [true, false].include? success
  }

  #### end override filters ##############

  def status_sym
    self.success ? :success : :failure
  end


  def disconnect_initiator_name
    DISCONNECTORS[self.disconnect_initiator_id].try(:name)
  end

  def has_dump?
    log_level_name.present?
  end

  def log_level_name
    if log_full?
      :Full
    elsif log_rtp?
      :RTP
    elsif log_sip?
      :SIP
    else
      nil
    end

  end

  def log_full?
    log_rtp? && log_sip?
  end

  def log_rtp?
    self.dump_level.log_rtp?
  end

  def log_sip?
    self.dump_level.log_sip?
  end

  def dump_filename
    if local_tag.present? && node_id.present?
      "/dump/#{local_tag}_#{node_id}.pcap"
    end
  end

  def call_record_filename_lega
    if local_tag.present? && node_id.present?
      "/record/#{local_tag}_legA.mp3"
    end
  end

  def call_record_filename_legb
    if local_tag.present? && node_id.present?
      "/record/#{local_tag}_legB.mp3"
    end
  end

  def attempts
    if self.local_tag.empty?
      self.class.where("cdr.id=?", self.id)
    else
      self.class.where(time_start: self.time_start).where(local_tag: self.local_tag).order('routing_attempt desc')
    end
  end

  def self.scoped_stat
    self.select("
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
    self.fetch_sp_val("select ev_new from pgq.get_queue_info('cdr_billing')")
  end

  def self.pending_events
    self.fetch_sp_val("select pending_events from pgq.get_consumer_info('cdr_billing', 'cdr_billing')")
  end

  private

  def self.ransackable_scopes(auth_object = nil)
    [
        :disconnect_code_eq,
        :status_eq,
        :account_id_eq
    ]
  end
end
