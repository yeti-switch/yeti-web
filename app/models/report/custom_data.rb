# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report_data
#
#  id                           :bigint(8)        not null, primary key
#  agg_asr_origination          :decimal(, )
#  agg_asr_termination          :decimal(, )
#  agg_calls_acd                :decimal(, )
#  agg_calls_count              :bigint(8)
#  agg_calls_duration           :bigint(8)
#  agg_customer_calls_duration  :bigint(8)
#  agg_customer_price           :decimal(, )
#  agg_customer_price_no_vat    :decimal(, )
#  agg_profit                   :decimal(, )
#  agg_short_calls_count        :bigint(8)
#  agg_successful_calls_count   :bigint(8)
#  agg_uniq_calls_count         :bigint(8)
#  agg_vendor_calls_duration    :bigint(8)
#  agg_vendor_price             :decimal(, )
#  auth_orig_ip                 :string
#  customer_billed              :boolean
#  customer_price               :decimal(, )
#  destination_fee              :decimal(, )
#  destination_initial_interval :integer(4)
#  destination_initial_rate     :decimal(, )
#  destination_next_interval    :integer(4)
#  destination_next_rate        :decimal(, )
#  dialpeer_fee                 :decimal(, )
#  dialpeer_initial_interval    :integer(4)
#  dialpeer_initial_rate        :decimal(, )
#  dialpeer_next_interval       :integer(4)
#  dialpeer_next_rate           :decimal(, )
#  diversion_in                 :string
#  diversion_out                :string
#  dst_prefix_in                :string
#  dst_prefix_out               :string
#  dump_file                    :string
#  duration                     :integer(4)
#  internal_disconnect_code     :integer(4)
#  internal_disconnect_reason   :string
#  is_last_cdr                  :boolean
#  lega_disconnect_code         :integer(4)
#  lega_disconnect_reason       :string
#  lega_user_agent              :string
#  legb_disconnect_code         :integer(4)
#  legb_disconnect_reason       :string
#  legb_user_agent              :string
#  local_tag                    :string
#  log_rtp                      :boolean
#  log_sip                      :boolean
#  p_charge_info_in             :string
#  profit                       :decimal(, )
#  routing_attempt              :integer(4)
#  sign_orig_ip                 :string
#  sign_orig_local_ip           :string
#  sign_orig_local_port         :integer(4)
#  sign_orig_port               :integer(4)
#  sign_term_ip                 :string
#  sign_term_local_ip           :string
#  sign_term_local_port         :integer(4)
#  sign_term_port               :integer(4)
#  src_name_in                  :string
#  src_name_out                 :string
#  src_prefix_in                :string
#  src_prefix_out               :string
#  success                      :boolean
#  time_connect                 :timestamptz
#  time_end                     :timestamptz
#  time_limit                   :string
#  time_start                   :timestamptz
#  vendor_billed                :boolean
#  vendor_price                 :decimal(, )
#  customer_acc_id              :integer(4)
#  customer_auth_id             :integer(4)
#  customer_id                  :integer(4)
#  customer_invoice_id          :integer(4)
#  destination_id               :integer(4)
#  destination_rate_policy_id   :integer(4)
#  dialpeer_id                  :integer(4)
#  disconnect_initiator_id      :integer(4)
#  dst_area_id                  :integer(4)
#  dst_country_id               :integer(4)
#  dst_network_id               :integer(4)
#  node_id                      :integer(4)
#  orig_call_id                 :string
#  orig_gw_id                   :integer(4)
#  pop_id                       :integer(4)
#  rateplan_id                  :integer(4)
#  report_id                    :integer(4)       not null
#  routing_group_id             :integer(4)
#  src_area_id                  :integer(4)
#  src_country_id               :integer(4)
#  src_network_id               :integer(4)
#  term_call_id                 :string
#  term_gw_id                   :integer(4)
#  vendor_acc_id                :integer(4)
#  vendor_id                    :integer(4)
#  vendor_invoice_id            :integer(4)
#
# Foreign Keys
#
#  cdr_custom_report_data_report_id_fkey  (report_id => cdr_custom_report.id)
#

class Report::CustomData < Cdr::Base
  self.table_name = 'reports.cdr_custom_report_data'

  belongs_to :report, class_name: 'Report::CustomCdr', foreign_key: :report_id

  belongs_to :rateplan, class_name: 'Routing::Rateplan', foreign_key: :rateplan_id, optional: true
  belongs_to :routing_group, class_name: 'Routing::RoutingGroup', foreign_key: :routing_group_id, optional: true

  belongs_to :orig_gw, class_name: 'Gateway', foreign_key: :orig_gw_id, optional: true
  belongs_to :term_gw, class_name: 'Gateway', foreign_key: :term_gw_id, optional: true
  belongs_to :destination, class_name: 'Routing::Destination', foreign_key: :destination_id, optional: true
  belongs_to :dialpeer, class_name: 'Dialpeer', foreign_key: :dialpeer_id, optional: true
  belongs_to :customer_auth, class_name: 'CustomersAuth', foreign_key: :customer_auth_id, optional: true
  belongs_to :vendor_acc, class_name: 'Account', foreign_key: :vendor_acc_id, optional: true
  belongs_to :customer_acc, class_name: 'Account', foreign_key: :customer_acc_id, optional: true
  belongs_to :vendor, class_name: 'Contractor', foreign_key: :vendor_id, optional: true # ,:conditions => {:vendor => true}
  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id, optional: true # ,  :conditions => {:customer => true}
  belongs_to :vendor_invoice, class_name: 'Billing::Invoice', foreign_key: :vendor_invoice_id, optional: true
  belongs_to :customer_invoice, class_name: 'Billing::Invoice', foreign_key: :customer_invoice_id, optional: true
  belongs_to :node, class_name: 'Node', foreign_key: :node_id, optional: true
  belongs_to :pop, class_name: 'Pop', foreign_key: :pop_id, optional: true
  belongs_to :dst_country, class_name: 'System::Country', foreign_key: :dst_country_id, optional: true
  belongs_to :dst_network, class_name: 'System::Network', foreign_key: :dst_network_id, optional: true
  belongs_to :src_country, class_name: 'System::Country', foreign_key: :src_country_id, optional: true
  belongs_to :src_network, class_name: 'System::Network', foreign_key: :src_network_id, optional: true
  belongs_to :src_area, class_name: 'Routing::Area', foreign_key: :src_area_id, optional: true
  belongs_to :dst_area, class_name: 'Routing::Area', foreign_key: :dst_area_id, optional: true

  def display_name
    id.to_s
  end

  def disconnect_initiator_name
    disconnect_initiator_id.nil? ? nil : Cdr::Cdr::DISCONNECT_INITIATORS[disconnect_initiator_id]
  end

  def destination_rate_policy_name
    destination_rate_policy_id.nil? ? nil : Routing::DestinationRatePolicy::POLICIES[destination_rate_policy_id]
  end

  def self.report_columns
    column_names.select { |column| column.start_with?('agg_') }
  end

  Totals = Struct.new(
    :agg_calls_count,
    :agg_successful_calls_count,
    :agg_short_calls_count,
    :agg_uniq_calls_count,
    :agg_calls_duration,
    :agg_customer_calls_duration,
    :agg_vendor_calls_duration,
    :agg_acd,
    :agg_customer_price,
    :agg_customer_price_no_vat,
    :agg_vendor_price,
    :agg_profit
  )

  def self.totals
    row = extending(ActsAsTotalsRelation).totals_row_by(
      'sum(agg_calls_count)::integer as agg_calls_count',
      'sum(agg_successful_calls_count)::integer as agg_successful_calls_count',
      'sum(agg_short_calls_count) as agg_short_calls_count',
      'sum(agg_uniq_calls_count) as agg_uniq_calls_count',
      'sum(agg_calls_duration) as agg_calls_duration',
      'sum(agg_customer_calls_duration) as agg_customer_calls_duration',
      'sum(agg_vendor_calls_duration) as agg_vendor_calls_duration',
      'coalesce(sum(agg_calls_duration)::float/nullif(sum(agg_successful_calls_count),0),0) as agg_acd',
      'sum(agg_customer_price) as agg_customer_price',
      'sum(agg_customer_price_no_vat) as agg_customer_price_no_vat',
      'sum(agg_vendor_price) as agg_vendor_price',
      'sum(agg_profit) as agg_profit'
    )
    Totals.new(*row)
  end
end
