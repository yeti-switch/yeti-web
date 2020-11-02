# frozen_string_literal: true

class Api::Rest::Admin::ActiveCallResource < ::BaseResource
  model_name 'RealtimeData::ActiveCall'
  paginator :none
  key_type :string

  attributes :start_time,
             :connect_time,
             :duration,
             :time_limit,
             :dst_prefix_in,
             :dst_prefix_routing,
             :lrn,
             :dst_prefix_out,
             :src_prefix_in,
             :src_prefix_routing,
             :src_prefix_out,
             :diversion_in,
             :diversion_out,
             :dst_country_id,
             :dst_network_id,
             :customer_id,
             :vendor_id,
             :customer_acc_id,
             :vendor_acc_id,
             :customer_auth_id,
             :destination_id,
             :dialpeer_id,
             :orig_gw_id,
             :term_gw_id,
             :routing_group_id,
             :rateplan_id,
             :destination_initial_rate,
             :destination_next_rate,
             :destination_initial_interval,
             :destination_next_interval,
             :destination_fee,
             :destination_rate_policy_id,
             :dialpeer_initial_rate,
             :dialpeer_next_rate,
             :dialpeer_initial_interval,
             :dialpeer_next_interval,
             :dialpeer_fee,
             :legA_remote_ip,
             :legA_remote_port,
             :orig_call_id,
             :legA_local_ip,
             :legA_local_port,
             :local_tag,
             :legB_local_ip,
             :legB_local_port,
             :term_call_id,
             :legB_remote_ip,
             :legB_remote_port,
             :node_id,
             :pop_id

  has_one :customer, class_name: 'Contractor'
  has_one :vendor, class_name: 'Contractor'
  has_one :customer_acc, class_name: 'Account'
  has_one :vendor_acc, class_name: 'Account'
  has_one :customer_auth, class_name: 'CustomersAuth'
  has_one :destination, class_name: 'Routing::Destination'
  has_one :dialpeer, class_name: 'Dialpeer'
  has_one :orig_gw, class_name: 'Gateway'
  has_one :term_gw, class_name: 'Gateway'
  has_one :routing_group, class_name: 'RoutingGroup'
  has_one :rateplan, class_name: 'Routing::Rateplan'
  has_one :destination_rate_policy, class_name: 'Routing::DestinationRatePolicy'
  has_one :node, class_name: 'Node', foreign_key: :node_id

  filter :node_id_eq
  filter :dst_country_id_eq
  filter :dst_network_id_eq
  filter :vendor_id_eq
  filter :customer_id_eq
  filter :vendor_acc_id_eq
  filter :customer_acc_id_eq
  filter :orig_gw_id_eq
  filter :term_gw_id_eq
  filter :duration_equals
  filter :duration_greater_than
  filter :duration_less_than

  def self.sortable_fields(_context = nil)
    []
  end

  def self.find_by_key(key, options = {})
    context = options[:context]
    opts = options.except(:paginator, :sort_criteria)
    model = apply_includes(records(opts), opts).find(key)
    raise JSONAPI::Exceptions::RecordNotFound, key if model.nil?

    new(model, context)
  end

  def self.sort_records(records, _order_options, _context = {})
    records
  end

  def self.find_count(_verified_filters, _options)
    0
  end
end
