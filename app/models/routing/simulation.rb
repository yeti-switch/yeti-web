# frozen_string_literal: true

class Routing::Simulation
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
      Rateplan.find_by(id: rateplan_id)
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

  include ActiveModel::Validations
  include ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :transport_protocol_id, :remote_ip, :remote_port, :src_number, :dst_number, :pop_id,
                :uri_domain, :from_domain, :to_domain,
                :x_yeti_auth, :release_mode,
                :pai, :ppi, :privacy, :rpid, :rpid_privacy

  validates_presence_of :remote_ip, :remote_port, :src_number, :dst_number, :pop_id
  validates_numericality_of :pop_id, :transport_protocol_id

  validates_numericality_of :remote_port,
                            greater_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MIN,
                            less_than: Yeti::ActiveRecord::L4_PORT_MAX,
                            allow_nil: true,
                            only_integer: true

  validate :ip_is_valid

  attr_reader :notices

  def initialize(attrs = {})
    @attrs = attrs
    unless attrs.blank?
      attrs.each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end
    end
  end

  def has_attributes?
    @attrs.present? && @attrs.to_unsafe_h.any?
  end

  def persisted?
    false
  end

  def debug
    @debug&.map { |d| Result.new(d) }
  end

  def save!
    return false unless has_attributes?

    @notices = []
    @debug = nil

    begin
      t = ActiveRecord::Base.connection.raw_connection.set_notice_processor { |result| @notices << result.to_s.chomp }
      Yeti::ActiveRecord.fetch_sp(
          "select * from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.init(?::integer, ?::integer)",
          1,
          1
      )
      @debug = Yeti::ActiveRecord.fetch_sp(
        "select * from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.debug(?::smallint,?::inet,?::integer,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        transport_protocol_id.to_i,
        remote_ip,
        remote_port.to_i,
        src_number,
        dst_number,
        pop_id.to_i,
        uri_domain,
        from_domain,
        to_domain,
        x_yeti_auth,
        release_mode,
        pai,
        ppi,
        privacy,
        rpid,
        rpid_privacy
      )
    rescue Exception => e
      p 'EXCEPTION'
      raise e
    ensure
      ActiveRecord::Base.connection.raw_connection.set_notice_processor(&t)
    end
    @notices.map! { |el| el.gsub('NOTICE:', '').gsub(/CONTEXT:.*/, '').gsub(%r{PL/pgSQL function .*}, '') }
  end

  protected

  def ip_is_valid
    _tmp = IPAddr.new(remote_ip)
  rescue IPAddr::Error => error
    errors.add(:remote_ip, 'is not valid')
  end
end
