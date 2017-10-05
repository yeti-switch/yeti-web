class RealtimeData::ActiveCall < YetiResource

  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Serializers::Xml

  attr_accessor :customer,
                :vendor,
                :customer_acc,
                :vendor_acc,
                :customer_auth,
                :destination,
                :dialpeer,
                :orig_gw,
                :term_gw,
                :routing_group,
                :rateplan,
                :destination_rate_policy,
                :dst_country,
                :dst_network,
                :node,
                :pop


  DYNAMIC_ATTRIBUTES = [
      :start_time,
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
  ]

  FOREIGN_KEYS_ATTRIBUTES = {
      customer_id: Contractor,
      vendor_id: Contractor,
      customer_acc_id: Account,
      vendor_acc_id: Account,
      customer_auth_id: CustomersAuth,
      dst_country_id: System::Country,
      dst_network_id: System::Network,
      destination_id: Destination,
      dialpeer_id: Dialpeer,
      orig_gw_id: Gateway,
      term_gw_id: Gateway,
      routing_group_id: RoutingGroup,
      rateplan_id: Rateplan,
      destination_rate_policy_id: DestinationRatePolicy,
      node_id: Node
  }

  # SHORT_DYNAMIC_ATTRIBUTES = [
  #     :duration,
  #     :dst_prefix_routing,
  #     :start_time,
  #     :connect_time,
  #     :destination_next_rate,
  #     :dialpeer_next_rate,
  #     :customer_id,
  #     :vendor_id,
  #     :dst_country_id,
  #     :dst_network_id
  # ]
  #
  #
  #
  # SHORT_FOREIGN_KEYS_ATTRIBUTES = {
  #     customer_id: Contractor,
  #     vendor_id: Contractor,
  #     dst_country_id: System::Country,
  #     dst_network_id: System::Network
  # }

  attr_accessor *DYNAMIC_ATTRIBUTES


#Customer, Vendor, Duration, dst_prefix_routing, Start time, connect time,dst country, Dst network, Destination next rate, Dialpeer next rate
  LIST_ATTRIBUTES = [
      :customer_id,
      :vendor_id,
      :duration,
      :dst_prefix_routing,
      :lrn,
      :start_time,
      :connect_time,
#      :dst_country_id,
      :dst_network_id,
      :destination_next_rate,
      :dialpeer_next_rate
  ]

  SYSTEM_ATTRIBUTES = [
      :node_id,
      :local_tag
  ]

 # TABLE_ATTRIBUTES = DYNAMIC_ATTRIBUTES

  def start_time
    DateTime.strptime(@start_time.to_s.split('.')[0], '%s').in_time_zone
  end

  def connect_time
    @connect_time.zero? ? nil : DateTime.strptime(@connect_time.to_s.split('.')[0], '%s').in_time_zone
  end

  def display_name
    self.local_tag
  end

  def duration=(d) # conversion to Int. Becouse we want see int duration on ActiveCalls page
    if d.is_a? Float
      d= d.to_i
    end
    @duration =d
  end

  def id
    [self.node_id.to_s,  self.local_tag].join("*")
  end

  # def to_param
  #   self.local_tag
  # end

  def self.list_attributes
    self.human_attributes(LIST_ATTRIBUTES)
  end

  def self.table_attributes
    self.human_attributes
  end

  def self.human_attribute_name(attribute_key_name, options = {})
    attribute_key_name
  end
  # def self.short_human_attributes
  #   self::SHORT_DYNAMIC_ATTRIBUTES - self::SHORT_FOREIGN_KEYS_ATTRIBUTES.keys + self::SHORT_FOREIGN_KEYS_ATTRIBUTES.keys.collect { |k| k.to_s[0..-4].to_sym }
  # end


end
