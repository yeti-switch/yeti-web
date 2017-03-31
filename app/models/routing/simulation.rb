class Routing::Simulation

  class Result < OpenStruct

    def vendor
      Contractor.find_by(id: self.vendor_id)
    end

    def customer
      Contractor.find_by(id: self.customer_id)
    end

    def customer_auth
      CustomersAuth.find_by(id: self.customer_auth_id)
    end

    def rateplan
      Rateplan.find_by(id: self.rateplan_id)
    end

    def routing_plan
      Routing::RoutingPlan.find_by(id: self.routing_plan_id)
    end

    def routing_group
      RoutingGroup.find_by(id: self.routing_group_id)
    end

    def destination
      Destination.find_by(id: self.destination_id)
    end

    def dialpeer
      Dialpeer.find_by(id: self.dialpeer_id)
    end

    def termination_gateway
      Gateway.find_by(id: self.term_gw_id)
    end

    def disconnect_code
      DisconnectCode.find_by(id: self.disconnect_code_id)
    end

    def dst_network
      System::Network.find_by(id: self.dst_network_id)
    end

    def dst_country
      System::Country.find_by(id: self.dst_country_id)
    end
  end


  include ActiveModel::Validations
  include ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :transport_protocol_id, :remote_ip, :remote_port, :src_number, :dst_number, :pop_id,
                :uri_domain, :from_domain, :to_domain,
                :x_yeti_auth

  validates_presence_of :remote_ip, :remote_port, :src_number, :dst_number, :pop_id
  validates_numericality_of :pop_id, :transport_protocol_id

  validates_numericality_of :remote_port,
                            greater_than_or_equal_to: Yeti::ActiveRecord::L4_PORT_MIN,
                            less_than: Yeti::ActiveRecord::L4_PORT_MAX,
                            allow_nil: true,
                            only_integer: true

  validate :ip_is_valid


  attr_reader :notices

  def initialize(attrs= {})
    @attrs =attrs
    attrs.each do |k, v|

      self.send("#{k}=", v) if self.respond_to?("#{k}=")
    end unless attrs.blank?

  end

  def has_attributes?
    @attrs.present? and @attrs.any?
  end

  def persisted?
    false
  end

  def debug
    @debug.map { |d| Result.new(d) } unless @debug.nil?
  end

  def save!
    return false unless has_attributes?
    @notices = []
    @debug = nil

    begin
      t = ActiveRecord::Base.connection.raw_connection.set_notice_processor { |result| @notices << result.to_s.chomp }
      @debug = Yeti::ActiveRecord.fetch_sp(
          "select * from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.debug(?::smallint,?::inet,?::integer,?,?,?,?,?,?,?)",
          self.transport_protocol_id.to_i,
          self.remote_ip,
          self.remote_port.to_i,
          self.src_number,
          self.dst_number,
          self.pop_id.to_i,
          self.uri_domain,
          self.from_domain,
          self.to_domain,
          self.x_yeti_auth
      )
    rescue Exception => e
      p "EXCEPTION"
      raise e
    ensure
      ActiveRecord::Base.connection.raw_connection.set_notice_processor(&t)

    end
    @notices.map! { |el| el.gsub("NOTICE:", "").gsub(/CONTEXT:.*/, '').gsub(/PL\/pgSQL function .*/, '') }

  end


  protected
  def ip_is_valid
    begin
      _tmp=IPAddr.new(remote_ip)
    rescue IPAddr::Error => error
      self.errors.add(:remote_ip, "is not valid")
    end
  end


end  