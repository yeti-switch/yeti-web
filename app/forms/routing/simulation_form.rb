# frozen_string_literal: true

class Routing::SimulationForm < ApplicationForm
  class Result < OpenStruct
    def vendor
      Contractor.find_by(id: vendor_id)
    end

    def customer
      Contractor.find_by(id: customer_id)
    end

    def customer_auth
      CustomersAuth.find_by(id: customer_auth_id)
    end

    def rateplan
      Routing::Rateplan.find_by(id: rateplan_id)
    end

    def routing_plan
      Routing::RoutingPlan.find_by(id: routing_plan_id)
    end

    def routing_group
      RoutingGroup.find_by(id: routing_group_id)
    end

    def destination
      Routing::Destination.find_by(id: destination_id)
    end

    def dialpeer
      Dialpeer.find_by(id: dialpeer_id)
    end

    def termination_gateway
      Gateway.find_by(id: term_gw_id)
    end

    def disconnect_code
      DisconnectCode.find_by(id: disconnect_code_id)
    end

    def dst_network
      System::Network.find_by(id: dst_network_id)
    end

    def dst_country
      System::Country.find_by(id: dst_country_id)
    end
  end

  attribute :transport_protocol_id
  attribute :remote_ip
  attribute :remote_port
  attribute :src_number
  attribute :dst_number
  attribute :pop_id
  attribute :uri_domain
  attribute :from_domain
  attribute :to_domain
  attribute :x_yeti_auth
  attribute :release_mode
  attribute :pai
  attribute :ppi
  attribute :privacy
  attribute :rpid
  attribute :rpid_privacy
  attribute :auth_id

  validates :remote_ip, :remote_port, :src_number, :dst_number, :pop_id, :transport_protocol_id, presence: true

  validates :pop_id, :transport_protocol_id, numericality: true

  validates :auth_id, numericality: {
    allow_nil: true,
    only_integer: true
  }

  validates :remote_port, numericality: {
    allow_nil: true,
    greater_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MIN,
    less_than: Yeti::ActiveRecord::L4_PORT_MAX,
    only_integer: true
  }

  validate :ip_is_valid

  attr_reader :notices

  def debug
    @debug&.map { |d| Result.new(d) }
  end

  protected

  def ip_is_valid
    _tmp = IPAddr.new(remote_ip)
  rescue IPAddr::Error => _error
    errors.add(:remote_ip, 'is not valid')
  end
end
