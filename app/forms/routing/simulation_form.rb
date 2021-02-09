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

  attribute :transport_protocol_id, :string
  attribute :remote_ip, :string
  attribute :remote_port, :string
  attribute :src_number, :integer
  attribute :dst_number, :integer
  attribute :pop_id, :string
  attribute :uri_domain, :string
  attribute :from_domain, :string
  attribute :to_domain, :string
  attribute :x_yeti_auth, :string
  attribute :release_mode, :string
  attribute :pai, :string
  attribute :ppi, :string
  attribute :privacy, :string
  attribute :rpid, :string
  attribute :rpid_privacy, :string
  attribute :auth_id, :integer

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

  validates :remote_ip, ip_address: true

  attr_reader :notices

  def debug
    @debug&.map { |d| Result.new(d) }
  end

  protected

  private

  def _save
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
      spname = release_mode == '1' ? 'route_release' : 'route_debug'
      @debug = Yeti::ActiveRecord.fetch_sp(
        "select * from #{Yeti::ActiveRecord::ROUTING_SCHEMA}.#{spname}(
          ?::integer, /* i_node_id integer */
          ?::integer, /* i_pop_id integer  */
          ?::smallint, /* i_protocol_id smallint */
          ?::inet, /* i_remote_ip inet */
          ?::integer, /* i_remote_port integer */
          ?::inet, /* i_local_ip inet */
          ?::integer, /* i_local_port integer */
          ?, /* i_from_dsp character varying */
          ?, /* i_from_name character varying */
          ?, /* i_from_domain character varying */
          ?, /* i_from_port integer */
          ?, /* i_to_name character varying */
          ?, /* i_to_domain character varying */
          ?::integer, /* i_to_port integer */
          ?, /* i_contact_name character varying */
          ?, /* i_contact_domain character varying */
          ?::integer, /* i_contact_port integer */
          ?, /* i_uri_name character varying */
          ?, /* i_uri_domain character varying */
          ?, /* i_auth_id integer */
          ?, /* i_x_yeti_auth character varying, */
          ?, /* i_diversion character varying */
          ?, /* i_x_orig_ip inet */
          ?, /* i_x_orig_port integer */
          ?, /* i_x_orig_protocol_id smallint */
          ?, /* i_pai character varying */
          ?, /* i_ppi character varying */
          ?, /* i_privacy character varying */
          ?, /* i_rpid character varying */
          ? /* i_rpid_privacy character varying */
          )",
        1, # node_id
        pop_id.to_i,
        transport_protocol_id.to_i,
        remote_ip,
        remote_port.to_i,
        '127.0.0.1', # local_ip
        5060, # local_port
        'from_name', # from name
        src_number,
        from_domain,
        5060,
        dst_number,
        to_domain,
        5060,
        src_number,
        remote_ip,
        remote_port,
        dst_number,
        uri_domain,
        auth_id,
        x_yeti_auth,
        nil,
        nil,
        nil,
        nil,
        pai,
        ppi,
        privacy,
        rpid,
        rpid_privacy
      )
    rescue Exception => e
      Rails.logger.info 'EXCEPTION'
      raise e
    ensure
      ActiveRecord::Base.connection.raw_connection.set_notice_processor(&t)
    end
    @notices.map! { |el| el.gsub('NOTICE:', '').gsub(/CONTEXT:.*/, '').gsub(%r{PL/pgSQL function .*}, '') }
  end
end
