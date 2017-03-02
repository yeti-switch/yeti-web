class DebugCall

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

  attr_accessor :remote_ip, :remote_port, :src_prefix, :dst_prefix , :pop_id, :uri_domain, :x_yeti_auth
  attr_accessor :customer_auth_id, :src_prefix, :dst_prefix , :pop_id

  #validates_presence_of :remote_ip, :remote_port, :src_prefix, :dst_prefix, :pop_id
  validates_presence_of :src_prefix, :dst_prefix

  attr_reader :notices

  def initialize(attrs= {})
    @attrs  =attrs
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

    @debug.map {|d| Result.new(d) }
    

  end

  def save!
    return false unless has_attributes?
    @notices = []
    @debug = nil

    if !self.customer_auth_id.nil?
      a=CustomersAuth.find(customer_auth_id)
      self.remote_ip=a.ip.to_s
      self.remote_port=5060
      self.pop_id=a.pop_id
      self.uri_domain=a.uri_domain
      self.x_yeti_auth=a.x_yeti_auth
    end

    begin
      t = ActiveRecord::Base.connection.raw_connection.set_notice_processor { |result| @notices << result.to_s.chomp }
      @debug = Yeti::ActiveRecord.fetch_sp("select * from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.debug(?,?,?,?,?,?,?)"  ,
                 self.remote_ip,
                 self.remote_port,
                 self.src_prefix,
                 self.dst_prefix,
                 self.pop_id,
                 self.uri_domain,
                 self.x_yeti_auth
      )
    ensure
      ActiveRecord::Base.connection.raw_connection.set_notice_processor(&t)

    end
    @notices.map! { |el| el.gsub("NOTICE:", "").gsub(/CONTEXT:.*/, '').gsub(/PL\/pgSQL function .*/, '') }

  end


end  