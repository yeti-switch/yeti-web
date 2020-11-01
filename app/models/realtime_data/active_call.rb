# frozen_string_literal: true

class RealtimeData::ActiveCall < YetiResource
  include ActiveModel::Validations
  include WithQueryBuilder

  class << self
    def query_builder_find(id, includes:, **_)
      node_id, local_tag = id.split('*')
      record = Node.find(node_id).active_call(local_tag)
      RealtimeData::ActiveCall.load_associations([record], *includes)
      record
    end

    def query_builder_collection(includes:, filters:, **_)
      result = Yeti::CdrsFilter.new(Node.all, filters).search(only: nil, empty_on_error: true)
      records = result.map { |item| RealtimeData::ActiveCall.new(item) }
      RealtimeData::ActiveCall.load_associations(records, *includes)
      records
    end
  end

  attribute :start_time, :yeti_date_time
  attribute :connect_time, :yeti_date_time
  attribute :duration, :integer
  attribute :time_limit
  attribute :dst_prefix_in
  attribute :dst_prefix_routing
  attribute :lrn
  attribute :dst_prefix_out
  attribute :src_prefix_in
  attribute :src_prefix_routing
  attribute :src_prefix_out
  attribute :diversion_in
  attribute :diversion_out
  attribute :dst_country_id, :integer
  attribute :dst_network_id, :integer
  attribute :customer_id, :integer
  attribute :vendor_id, :integer
  attribute :customer_acc_id, :integer
  attribute :vendor_acc_id, :integer
  attribute :customer_auth_id, :integer
  attribute :destination_id, :integer
  attribute :dialpeer_id, :integer
  attribute :orig_gw_id, :integer
  attribute :term_gw_id, :integer
  attribute :routing_group_id, :integer
  attribute :rateplan_id, :integer
  attribute :destination_initial_rate
  attribute :destination_next_rate
  attribute :destination_initial_interval
  attribute :destination_next_interval
  attribute :destination_fee
  attribute :destination_rate_policy_id
  attribute :dialpeer_initial_rate
  attribute :dialpeer_next_rate
  attribute :dialpeer_initial_interval
  attribute :dialpeer_next_interval
  attribute :dialpeer_fee
  attribute :legA_remote_ip
  attribute :legA_remote_port
  attribute :orig_call_id
  attribute :legA_local_ip
  attribute :legA_local_port
  attribute :local_tag
  attribute :legB_local_ip
  attribute :legB_local_port
  attribute :term_call_id
  attribute :legB_remote_ip
  attribute :legB_remote_port
  attribute :node_id, :integer
  attribute :pop_id, :integer

  has_one :customer, class_name: 'Contractor', foreign_key: :customer_id
  has_one :vendor, class_name: 'Contractor', foreign_key: :vendor_id
  has_one :customer_acc, class_name: 'Account', foreign_key: :customer_acc_id
  has_one :vendor_acc, class_name: 'Account', foreign_key: :vendor_acc_id
  has_one :customer_auth, class_name: 'CustomersAuth', foreign_key: :customer_auth_id
  has_one :destination, class_name: 'Routing::Destination', foreign_key: :destination_id
  has_one :dialpeer, class_name: 'Dialpeer', foreign_key: :dialpeer_id
  has_one :orig_gw, class_name: 'Gateway', foreign_key: :orig_gw_id
  has_one :term_gw, class_name: 'Gateway', foreign_key: :term_gw_id
  has_one :routing_group, class_name: 'RoutingGroup', foreign_key: :routing_group_id
  has_one :rateplan, class_name: 'Routing::Rateplan', foreign_key: :rateplan_id
  has_one :destination_rate_policy, class_name: 'Routing::DestinationRatePolicy', foreign_key: :destination_rate_policy_id
  has_one :dst_country, class_name: 'System::Country', foreign_key: :dst_country_id
  has_one :dst_network, class_name: 'System::Network', foreign_key: :dst_network_id
  has_one :node, class_name: 'Node', foreign_key: :node_id
  has_one :pop, class_name: 'Pop', foreign_key: :pop_id

  def display_name
    local_tag
  end

  def id
    [node_id.to_s, local_tag].join('*')
  end

  def destroy
    self.node ||= Node.find(node_id)
    node.drop_call(local_tag)
    true
  rescue StandardError => e
    logger.error { "<#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
    errors.add(:base, e.message)
    false
  end

  def self.list_attributes
    human_attributes(LIST_ATTRIBUTES)
  end
end
