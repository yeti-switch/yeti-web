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
             :legB_remote_port

  has_one :customer, class_name: 'Contractor'
  has_one :vendor, class_name: 'Contractor'
  has_one :customer_acc, class_name: 'Account'
  has_one :vendor_acc, class_name: 'Account'
  has_one :customer_auth, class_name: 'CustomersAuth'
  has_one :rateplan, class_name: 'Rateplan'
  has_one :destination, class_name: 'Destination'
  has_one :routing_group, class_name: 'RoutingGroup'
  has_one :routing_plan, class_name: 'RoutingGroup'
  has_one :dialpeer, class_name: 'Dialpeer'
  has_one :orig_gw, class_name: 'Gateway'
  has_one :term_gw, class_name: 'Gateway'
  has_one :src_country, class_name: 'Country', foreign_key: :src_country_id
  has_one :src_network, class_name: 'Network', foreign_key: :src_network_id
  has_one :dst_country, class_name: 'Country', foreign_key: :dst_country_id
  has_one :dst_network, class_name: 'Network', foreign_key: :dst_network_id
  has_one :pop, class_name: 'Pop', foreign_key: :node_id
  has_one :node, class_name: 'Node', foreign_key: :node_id

  filter :customer_id_eq
  filter :vendor_id_eq
  filter :customer_acc_id_eq
  filter :vendor_acc_id_eq
  filter :customer_auth_id_eq
  filter :rateplan_id_eq
  filter :destination_id_eq
  filter :routing_group_id_eq
  filter :routing_plan_id_eq
  filter :dialpeer_id_eq
  filter :orig_gw_id_eq
  filter :term_gw_id_eq
  filter :src_country_id_eq
  filter :src_network_id_eq
  filter :dst_country_id_eq
  filter :dst_network_id_eq
  filter :pop_id_eq
  filter :node_id_eq
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
  rescue RealtimeData::ActiveNode::Error, Node::Error => _e
    raise JSONAPI::Exceptions::RecordNotFound, key
  end

  def self.sort_records(records, _order_options, _context = {})
    records
  end

  def self.find_count(_verified_filters, _options)
    0
  end
end
