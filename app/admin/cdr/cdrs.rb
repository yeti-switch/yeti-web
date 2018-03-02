ActiveAdmin.register Cdr::Cdr, as: 'CDR' do
  menu parent: 'CDR', priority: 95, label: 'CDR history'

  actions :index, :show
  config.batch_actions = false
  acts_as_cdr_stat

  before_filter do
    if params['q'].blank?
      from_date = 0.days.ago.beginning_of_day
      params['q'] = {time_start_gteq: from_date} # only 1 last days by default
      flash.now[:notice] = "Only CDRs started from #{from_date}  showed by default"
    else
      # fix this with right filter setup
      params['q']['account_id_eq'] = params['q']['account_id_eq'].to_i if params['q']['account_id_eq'].present?
      params['q']['disconnect_code_eq'] = params['q']['disconnect_code_eq'].to_i if params['q']['disconnect_code_eq'].present?
    end
  end

  controller do
    def columns_visibility?
      true
    end

    def scoped_collection
      if params[:as] == 'table'
        super.preload(
            :dump_level,
            :node,
            :pop,
            :disconnect_initiator,
            :lb_node
        )
      else
        super.preload(
            :pop, :node, :customer_auth,
            :customer, :vendor, :dump_level,
            :disconnect_initiator, :customer_acc, :vendor_acc,
            :orig_gw, :term_gw,
            :rateplan, :routing_plan, :routing_group,
            :destination, :dialpeer, :destination_rate_policy,
            :dst_country, :dst_network,
            :sign_orig_transport_protocol, :auth_orig_transport_protocol, :sign_term_transport_protocol
        )
      end
    end
  end

  scope :all, show_count: false
  scope :successful_calls, show_count: false
  scope :short_calls, show_count: false
  scope :rerouted_calls, show_count: false
  scope :with_trace, show_count: false
  scope :no_rtp, show_count: false
  scope :not_authorized, show_count: false
  scope :bad_routing, show_count: false



  filter :id
  filter :time_start, as: :date_time_range
  filter :customer, collection: proc { Contractor.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :vendor, collection: proc { Contractor.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :customer_auth, collection: proc { CustomersAuth.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :src_prefix_routing
  filter :src_area, collection: proc { Routing::Area.select([:id, :name]) }, input_html: {class: 'chosen'}
  filter :dst_prefix_routing
  filter :dst_area, collection: proc { Routing::Area.select([:id, :name]) }, input_html: {class: 'chosen'}
  filter :dst_country, input_html: {class: 'chosen'}
  filter :status, as: :select, collection: proc { [['FAILURE', false], ['SUCCESS', true]] }
  filter :duration
  filter :is_last_cdr, as: :select, collection: proc { [['Yes', true], ['No', false]] }
  filter :dump_level, as: :select, collection: DumpLevel.select([:id, :name]).reorder(:id)

  filter :orig_gw, collection: proc { Gateway.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :term_gw, collection: proc { Gateway.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :routing_plan, collection: proc { Routing::RoutingPlan.select([:id, :name]) }, input_html: {class: 'chosen'}
  filter :routing_group, collection: proc { RoutingGroup.select([:id, :name]) }, input_html: {class: 'chosen'}
#  filter :routing_tag, collection: proc { Routing::RoutingTag.select([:id, :name]) }, input_html: {class: 'chosen'}
  filter :rateplan, collection: proc { Rateplan.select([:id, :name]) }, input_html: {class: 'chosen'}

  filter :internal_disconnect_code, as: :string_eq
  filter :internal_disconnect_reason, as: :string_eq
  filter :lega_disconnect_code, as: :string_eq
  filter :lega_disconnect_reason, as: :string_eq
  filter :legb_disconnect_code, as: :string_eq
  filter :legb_disconnect_reason, as: :string_eq

  filter :src_prefix_in, as: :string_eq
  filter :dst_prefix_in, as: :string_eq
  filter :src_prefix_out
  filter :dst_prefix_out
  filter :lrn
  filter :diversion_in, as: :string_eq
  filter :diversion_out, as: :string_eq
  filter :src_name_in, as: :string_eq
  filter :src_name_out, as: :string_eq
  filter :node, input_html: {class: 'chosen'}
  filter :pop, input_html: {class: 'chosen'}
  filter :local_tag
  filter :orig_call_id, as: :string
  filter :term_call_id, as: :string
  filter :routing_attempt
  filter :customer_price
  filter :vendor_price
  filter :vendor_invoice_id
  filter :customer_invoice_id

  filter :routing_delay
  filter :pdd
  filter :rtt


  # X-Accel-Redirect: /protected/iso.img;
  #  location /protected/ {
  #  internal;
  #  root   /some/path;
  #}
  member_action :dump, method: :get do
    file=resource.dump_filename
    if file.blank?
      raise ActiveRecord::RecordNotFound
    end
    response.headers['X-Accel-Redirect'] = file
    head :ok
  end

  member_action :download_call_record_lega, method: :get do
    file=resource.call_record_filename_lega
    if file.blank?
      raise ActiveRecord::RecordNotFound
    end
    response.headers['X-Accel-Redirect'] = file
    head :ok
  end

  member_action :download_call_record_legb, method: :get do
    file=resource.call_record_filename_legb
    if file.blank?
      raise ActiveRecord::RecordNotFound
    end
    response.headers['X-Accel-Redirect'] = file
    head :ok
  end


  member_action :routing_simulation, method: :get do

    @cdr = Cdr::Cdr.find(params[:id])
    @proto =  @cdr.auth_orig_transport_protocol_id.nil? ? 1 : @cdr.auth_orig_transport_protocol_id #proto = UDP if no info in DB
    redirect_to routing_simulation_path({routing_simulation: {
                                    transport_protocol_id: @proto,
                                    remote_ip: @cdr.auth_orig_ip,
                                    remote_port: @cdr.auth_orig_port,
                                    src_number: @cdr.src_prefix_in,
                                    dst_number: @cdr.dst_prefix_in,
                                    pop_id: @cdr.pop_id,
                                    x_yeti_auth: @cdr.customer_auth.try!(:x_yeti_auth),
                                    uri_domain: @cdr.ruri_domain,
                                    from_domain: @cdr.from_domain,
                                    to_domain: @cdr.to_domain,
                                    pai: @cdr.pai_in,
                                    ppi: @cdr.ppi_in,
                                    privacy: @cdr.privacy_in,
                                    rpid: @cdr.rpid_in,
                                    rpid_privacy: @cdr.rpid_privacy_in
                                }, anchor: 'detailed'})
  end


  action_item :routing_simulation, only: :show do
    link_to('Routing simulation', routing_simulation_cdr_path(resource))
  end

  action_item :log_level_trace, only: :show do
    link_to("#{resource.log_level_name} trace", dump_cdr_path(resource)) if resource.has_dump?
  end

  action_item :call_record_lega, only: :show do
    link_to("Call record LegA", download_call_record_lega_cdr_path(resource)) if resource.audio_recorded?
  end

  action_item :call_record_lega, only: :show do
    link_to("Call record LegB", download_call_record_legb_cdr_path(resource)) if resource.audio_recorded?
  end

  action_item :download_csv, only: :index do
    dropdown_menu 'Download CSV' do

      item(
          'Full CSV',
          cdrs_path({format: :csv, q: params[:q], order: params[:order], scope: params[:scope], csv_policy: 'all'})
      )
      item(
          'CSV for Customer leg',
          cdrs_path({format: :csv, q: params[:q].merge(is_last_cdr_eq: true), order: params[:order], scope: params[:scope], csv_policy: 'customer'})
      )
      item(
          'CSV for Vendor leg',
          cdrs_path({format: :csv, q: params[:q], order: params[:order], scope: params[:scope], csv_policy: 'vendor'})
      )

    end
  end



  show do |cdr|
    panel "Attempts" do
      table_for cdr.attempts do
        column(:id) do |cdr|
          link_to cdr.id, resource_path(cdr), class: 'resource_id_link'
        end
        column :time_start
        column :time_connect
        column :time_end

        column(:duration, class: 'seconds') do |cdr|
          "#{cdr.duration} sec."
        end
        column('LegA DC') do |cdr|
          status_tag(cdr.lega_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.lega_disconnect_code==0 or cdr.lega_disconnect_code.nil?)
        end
        column('LegA Reason') do |cdr|
          cdr.lega_disconnect_reason #unless cdr.lega_disconnect_code==0
        end
        column('DC') do |cdr|
          status_tag(cdr.internal_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.internal_disconnect_code==0 or cdr.internal_disconnect_code.nil?)
        end
        column('Reason') do |cdr|
          cdr.internal_disconnect_reason #unless cdr.internal_disconnect_code==0
        end
        column('LegB DC') do |cdr|
          status_tag(cdr.legb_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.legb_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
        end
        column('LegB Reason') do |cdr|
          cdr.legb_disconnect_reason #unless cdr.legb_disconnect_code==0
        end
        column :disconnect_initiator do |cdr|
          "#{cdr.disconnect_initiator_id} - #{cdr.disconnect_initiator_name}"
        end
        column :routing_attempt do |cdr|
          status_tag(cdr.routing_attempt.to_s, class: cdr.is_last_cdr? ? :ok : nil)
        end
        column :src_name_in
        column :src_prefix_in
        column :from_domain
        column :dst_prefix_in
        column :to_domain
        column :ruri_domain
        column :src_prefix_routing
        column :src_area
        column :dst_prefix_routing
        column :dst_area
        column :lrn
        column :lnp_database
        column :src_name_out
        column :src_prefix_out
        column :dst_prefix_out
        column :diversion_in
        column :diversion_out

        column :dst_country
        column :dst_network

        column :node
        column :pop
        column :customer
        column :vendor
        column :customer_acc
        column :vendor_acc
        column :customer_auth
        column :orig_gw

        column :sign_orig_transport_protocol

        column(:sign_orig_ip) do |cdr|
          "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(":")
        end
        column(:sign_orig_local_ip) do |cdr|
          "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(":")
        end

        column :auth_orig_transport_protocol
        column :auth_orig_ip do |cdr|
          "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(":")
        end

        column :term_gw
        column :sign_term_transport_protocol
        column(:sign_term_ip) do |cdr|
          "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(":")
        end
        column(:sign_term_local_ip) do |cdr|
          "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(":")
        end
        column :is_redirected
        column :routing_delay
        column :pdd
        column :rtt
        column :early_media_present
        column('Status') do |cdr|
          status_tag(cdr.status_sym.to_s, cdr.status_sym, class: cdr.success? ? :ok : nil)
        end
        column :rateplan
        column :destination
        column :destination_rate_policy
        column :destination_fee
        column :destination_initial_interval
        column :destination_initial_rate
        column :destination_next_interval
        column :destination_next_rate
        column :customer_price
        column :customer_price_no_vat
        column :customer_duration
        column :routing_plan
        column :routing_group
        column :routing_tag_ids
        column :dialpeer
        column :dialpeer_fee
        column :dialpeer_initial_interval
        column :dialpeer_initial_rate
        column :dialpeer_next_interval
        column :dialpeer_next_rate
        column :vendor_price
        column :vendor_duration
        column :time_limit
        column :profit
        column('Orig call') do |cdr|
          cdr.orig_call_id
        end
        column :local_tag
        column('Term call') do |cdr|
          cdr.term_call_id
        end
        column :customer_invoice_id
        column :vendor_invoice_id

        column :pai_in
        column :ppi_in
        column :privacy_in
        column :rpid_in
        column :rpid_privacy_in
        column :pai_out
        column :ppi_out
        column :privacy_out
        column :rpid_out
        column :rpid_privacy_out

        column :lega_rx_payloads
        column :lega_tx_payloads
        column :legb_rx_payloads
        column :legb_tx_payloads

        column :lega_rx_bytes
        column :lega_tx_bytes
        column :lega_rx_decode_errs
        column :lega_rx_no_buf_errs
        column :lega_rx_parse_errs

        column :legb_rx_bytes
        column :legb_tx_bytes
        column :legb_rx_decode_errs
        column :legb_rx_no_buf_errs
        column :legb_rx_parse_errs
        column :core_version
        column :yeti_version
        column :lega_user_agent
        column :legb_user_agent
        column :uuid

        column :failed_resource_type_id
        column :failed_resource_id

        column :customer_external_id
        column :customer_auth_external_id
        column :customer_acc_vat
        column :customer_acc_external_id

        column :vendor_external_id
        column :vendor_acc_external_id
        column :orig_gw_external_id
        column :term_gw_external_id

      end if cdr.attempts.length > 0
    end

    tabs do
      tab :general_information do
        attributes_table do
          row :id
          row :uuid
          row :time_start
          row :time_connect
          row :time_end
          row :duration
          row :status do
            status_tag(cdr.status_sym.to_s, cdr.status_sym, class: cdr.success? ? :ok : nil)
          end
          row :disconnect_initiator do
            "#{cdr.disconnect_initiator_id} - #{cdr.disconnect_initiator_name}"
          end
          row :lega_disconnect_code
          row :lega_disconnect_reason
          row :internal_disconnect_code
          row :internal_disconnect_reason
          row :legb_disconnect_code
          row :legb_disconnect_reason
          row :routing_attempt
          row :is_last_cdr
          row :src_name_in
          row :src_prefix_in
          row :from_domain
          row :dst_prefix_in
          row :to_domain
          row :ruri_domain
          row :src_prefix_routing
          row :src_area
          row :dst_prefix_routing
          row :dst_area

          row :lrn
          row :lnp_database

          row :src_name_out
          row :src_prefix_out
          row :dst_prefix_out

          row :diversion_in
          row :diversion_out

          row :dst_country
          row :dst_network

          row :node
          row :pop

          row :customer
          row :customer_external_id
          row :vendor
          row :vendor_external_id
          row :customer_acc
          row :customer_acc_external_id
          row :vendor_acc
          row :vendor_acc_external_id
          row :customer_auth
          row :orig_gw
          row :orig_gw_external_id
          row :term_gw
          row :term_gw_external_id

        end

      end
      tab :protocol_details do
        attributes_table do
          row :orig_call do
            cdr.orig_call_id
          end
          row :term_call do
            cdr.term_call_id
          end
          row :sign_orig_transport_protocol
          row :sign_orig_ip do
            "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(":")
          end

          row :sign_orig_local_ip do
            "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(":")
          end

          row :auth_orig_transport_protocol
          row :auth_orig_ip do
            "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(":")
          end

          row :sign_term_transport_protocol
          row :sign_term_ip do
            "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(":")
          end
          row :sign_term_local_ip do
            "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(":")
          end

          row :is_redirected

          row :local_tag
          row :routing_delay
          row :pdd
          row :rtt
          row :early_media_present
          row :lega_rx_payloads
          row :lega_tx_payloads
          row :legb_rx_payloads
          row :legb_tx_payloads

          row :lega_rx_bytes
          row :lega_tx_bytes
          row :lega_rx_decode_errs
          row :lega_rx_no_buf_errs
          row :lega_rx_parse_errs

          row :legb_rx_bytes
          row :legb_tx_bytes
          row :legb_rx_decode_errs
          row :legb_rx_no_buf_errs
          row :legb_rx_parse_errs
          row :core_version
          row :yeti_version
          row :lega_user_agent
          row :legb_user_agent
        end

      end

      tab 'Routing&Billing information' do
        attributes_table do
          row :customer_price
          row :customer_price_no_vat
          row :customer_duration
          row :vendor_price
          row :vendor_duration
          row :profit

          row :rateplan
          row :destination
          row :destination_rate_policy
          row :destination_fee
          row :destination_initial_interval
          row :destination_initial_rate
          row :destination_next_interval
          row :destination_next_rate

          row :routing_plan
          row :routing_group
          row :routing_tag_ids
          row :dialpeer

          row :dialpeer_fee
          row :dialpeer_initial_interval
          row :dialpeer_initial_rate
          row :dialpeer_next_interval
          row :dialpeer_next_rate

          row :time_limit

          row :customer_invoice_id
          row :vendor_invoice_id

        end
      end
      tab :privacy_information do
        attributes_table do
          row :pai_in
          row :ppi_in
          row :privacy_in
          row :rpid_in
          row :rpid_privacy_in
          row :pai_out
          row :ppi_out
          row :privacy_out
          row :rpid_out
          row :rpid_privacy_out
        end
      end
    end
  end


  index download_links: false do
    column :id do |cdr|
      if cdr.dump_level_id>0
        link_to( cdr.id, resource_path(cdr), class: "resource_id_link", title: 'Details') + " " + link_to(fa_icon('exchange'), dump_cdr_path(cdr), title: 'Download trace')
      else
        link_to( cdr.id, resource_path(cdr), class: "resource_id_link", title: 'Details')
      end
    end

    column :time_start
    column :time_connect
    column :time_end

    column(:duration, sortable: 'duration', class: "seconds") do |cdr|
      "#{cdr.duration} sec."
    end
    column('LegA DC', sortable: 'lega_disconnect_code') do |cdr|
      status_tag(cdr.lega_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.lega_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
    end
    column('LegA Reason', sortable: 'lega_disconnect_reason') do |cdr|
      cdr.lega_disconnect_reason #unless cdr.lega_disconnect_code==0
    end
    column('DC', sortable: 'internal_disconnect_code') do |cdr|
      status_tag(cdr.internal_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.internal_disconnect_code==0 or cdr.internal_disconnect_code.nil?)
    end
    column('Reason', sortable: 'internal_disconnect_reason') do |cdr|
      cdr.internal_disconnect_reason #unless cdr.internal_disconnect_code==0
    end
    column('LegB DC', sortable: 'legb_disconnect_code') do |cdr|
      status_tag(cdr.legb_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.legb_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
    end
    column('LegB Reason', sortable: 'legb_disconnect_reason') do |cdr|
      cdr.legb_disconnect_reason #unless cdr.legb_disconnect_code==0
    end
    column :disconnect_initiator do |cdr|
      "#{cdr.disconnect_initiator_id} - #{cdr.disconnect_initiator_name}"
    end
    column :routing_attempt do |cdr|
      status_tag(cdr.routing_attempt.to_s, class: cdr.is_last_cdr? ? :ok : nil)
    end

    #column :routing_attempt 
    #column :is_last_cdr

    column :src_name_in
    column :src_prefix_in
    column :from_domain
    column :dst_prefix_in
    column :to_domain
    column :ruri_domain
    column :src_prefix_routing
    column :src_area
    column :dst_prefix_routing
    column :dst_area

    column :lrn
    column :lnp_database
    column :src_name_out
    column :src_prefix_out
    column :dst_prefix_out

    column :diversion_in
    column :diversion_out
    column :dst_country
    column :dst_network

    column :node
    column :pop
    column :customer
    column :vendor
    column :customer_acc
    column :vendor_acc
    column :customer_auth
    column :orig_gw


    column('LegA remote socket', sortable: 'sign_orig_ip') do |cdr|
      if cdr.sign_orig_transport_protocol_id.nil?
        "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(":")
      else
        "#{cdr.sign_orig_transport_protocol.name}://#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(":")
      end
    end
    column('LegA local socket', sortable: 'sign_orig_local_ip') do |cdr|
      "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(":")
    end
    column('LegA originator address', sotrable: 'auth_orig_ip') do |cdr|
      if cdr.auth_orig_transport_protocol_id.nil?
        "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(":")
      else
        "#{cdr.auth_orig_transport_protocol.name}://#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(":")
      end
    end
    column :term_gw
    column('LegB remote socket', sortable: :sign_term_ip) do |cdr|
      if cdr.sign_term_transport_protocol_id.nil?
        "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(":")
      else
        "#{cdr.sign_term_transport_protocol.name}://#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(":")
      end
    end
    column('LegB local socket', sortable: 'sign_term_local_ip') do |cdr|
      "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(":")
    end
    column :is_redirected
    column :routing_delay
    column :pdd
    column :rtt
    column :early_media_present
    column('Status', sortable: 'success') do |cdr|
      status_tag(cdr.status_sym.to_s, cdr.status_sym, class: cdr.success? ? :ok : nil)
    end
    column :rateplan
    column :destination
    column :destination_rate_policy
    column :destination_fee
    column :destination_initial_interval
    column :destination_initial_rate
    column :destination_next_interval
    column :destination_next_rate
    column :customer_price
    column :customer_acc_vat
    column :customer_price_no_vat
    column :customer_duration
    column :routing_plan
    column :routing_group
    column :routing_tag_ids
    column :dialpeer

    column :dialpeer_fee
    column :dialpeer_initial_interval
    column :dialpeer_initial_rate
    column :dialpeer_next_interval
    column :dialpeer_next_rate
    column :vendor_price
    column :vendor_duration
    column :time_limit
    column :profit
    column :orig_call_id
    column :local_tag
    column :term_call_id
    column :customer_invoice_id
    column :vendor_invoice_id

    column :pai_in
    column :ppi_in
    column :privacy_in
    column :rpid_in
    column :rpid_privacy_in
    column :pai_out
    column :ppi_out
    column :privacy_out
    column :rpid_out
    column :rpid_privacy_out

    column :lega_rx_payloads
    column :lega_tx_payloads
    column :legb_rx_payloads
    column :legb_tx_payloads

    column :lega_rx_bytes
    column :lega_tx_bytes
#    column :lega_rx_decode_errs
#    column :lega_rx_no_buf_errs
#    column :lega_rx_parse_errs

    column :legb_rx_bytes
    column :legb_tx_bytes
#    column :legb_rx_decode_errs
#    column :legb_rx_no_buf_errs
#    column :legb_rx_parse_errs

    column :core_version
    column :yeti_version
    column :lega_user_agent
    column :legb_user_agent
    column :uuid
    column :failed_resource_id
    column :failed_resource_type_id
  end


  csv do
    policy = params[:csv_policy]
    case policy
      when 'customer'
        column :time_start
        column :time_connect
        column :time_end
        column(:duration, sortable: 'duration', class: 'seconds') do |cdr|
          "#{cdr.duration} sec."
        end
        column('Status', sortable: 'success') do |cdr|
          cdr.status_sym.to_s
        end
        column :destination_initial_interval
        column :destination_initial_rate
        column :destination_next_interval
        column :destination_next_rate
        column :destination_fee
        column :customer_price
        column :src_name_in
        column :src_prefix_in
        column :from_domain
        column :dst_prefix_in
        column :to_domain
        column :ruri_domain
        column :diversion_in
        column :local_tag
        column('LegA DC', sortable: 'lega_disconnect_code') do |cdr|
          cdr.lega_disconnect_code.to_s unless (cdr.lega_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
        end
        column('LegA Reason', sortable: 'lega_disconnect_reason') do |cdr|
          cdr.lega_disconnect_reason #unless cdr.lega_disconnect_code==0
        end
        column :lega_rx_payloads
        column :lega_tx_payloads
        column :auth_orig_transport_protocol
        column :auth_orig_ip do |cdr|
          "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(':')
        end
        column :lega_rx_bytes
        column :lega_tx_bytes
        column :lega_rx_decode_errs
        column :lega_rx_no_buf_errs
        column :lega_rx_parse_errs
        column :src_prefix_routing
        column :dst_prefix_routing
        column :destination_prefix


      when 'vendor'
        column :time_start
        column :time_connect
        column :time_end
        column(:duration, sortable: 'duration', class: 'seconds') do |cdr|
          "#{cdr.duration} sec."
        end
        column('Status', sortable: 'success') do |cdr|
          cdr.status_sym.to_s
        end
        column :dialpeer_fee
        column :dialpeer_initial_interval
        column :dialpeer_initial_rate
        column :dialpeer_next_interval
        column :dialpeer_next_rate
        column :dialpeer_prefix
        column :vendor_price
        column :src_prefix_out
        column :dst_prefix_out
        column :src_name_out
        column :diversion_out
        column :sign_term_transport_protocol
        column(:sign_term_ip, sortable: :sign_term_ip) do |cdr|
          "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(':')
        end
        column(:sign_term_local_ip, sortable: 'sign_term_local_ip') do |cdr|
          "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(':')
        end
        column :local_tag
        column('LegB DC', sortable: 'legb_disconnect_code') do |cdr|
          cdr.legb_disconnect_code.to_s unless (cdr.legb_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
        end
        column('LegB Reason', sortable: 'legb_disconnect_reason') do |cdr|
          cdr.legb_disconnect_reason #unless cdr.legb_disconnect_code==0
        end
        column :legb_rx_payloads
        column :legb_tx_payloads
        column :legb_rx_bytes
        column :legb_tx_bytes
        column :legb_rx_decode_errs
        column :legb_rx_no_buf_errs
        column :legb_rx_parse_errs
        column :pdd
        column :rtt
        column :early_media_present


      when 'all'
        column :id
        column :time_start
        column :time_connect
        column :time_end
        column(:duration, sortable: 'duration', class: 'seconds') do |cdr|
          "#{cdr.duration} sec."
        end
        column('LegA DC', sortable: 'lega_disconnect_code') do |cdr|
          cdr.lega_disconnect_code.to_s unless (cdr.lega_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
        end
        column('LegA Reason', sortable: 'lega_disconnect_reason') do |cdr|
          cdr.lega_disconnect_reason #unless cdr.lega_disconnect_code==0
        end
        column('DC', sortable: 'internal_disconnect_code') do |cdr|
          cdr.internal_disconnect_code.to_s unless (cdr.internal_disconnect_code==0 or cdr.internal_disconnect_code.nil?)
        end
        column('Reason', sortable: 'internal_disconnect_reason') do |cdr|
          cdr.internal_disconnect_reason #unless cdr.internal_disconnect_code==0
        end
        column('LegB DC', sortable: 'legb_disconnect_code') do |cdr|
          cdr.legb_disconnect_code.to_s unless (cdr.legb_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
        end
        column('LegB Reason', sortable: 'legb_disconnect_reason') do |cdr|
          cdr.legb_disconnect_reason #unless cdr.legb_disconnect_code==0
        end
        column :disconnect_initiator do |cdr|
          "#{cdr.disconnect_initiator_id} - #{cdr.disconnect_initiator_name}"
        end
        column :routing_attempt do |cdr|
          "#{cdr.routing_attempt} #{cdr.is_last_cdr? ? '(last)' : ''}"
        end
        column :src_name_in
        column :src_prefix_in
        column :dst_prefix_in
        column :src_prefix_routing
        column :src_area
        column :dst_prefix_routing
        column :dst_area
        column :lrn
        column :lnp_database
        column :src_name_out
        column :src_prefix_out
        column :dst_prefix_out
        column :diversion_in
        column :diversion_out
        column :dst_country
        column :dst_network
        column :node do |row|
          "#{row.node.name} ##{row.node.id}" if row.node.present?
        end
        column :pop do |row|
          "#{row.pop.name} ##{row.pop.id}" if row.pop.present?
        end
        column :customer do |row|
          "#{row.customer.name} ##{row.customer.id}" if row.customer.present?
        end
        column :vendor do |row|
          "#{row.vendor.name} ##{row.vendor.id}" if row.vendor.present?
        end
        column :customer_acc do |row|
          "#{row.customer_acc.name} ##{row.customer_acc.id}" if row.customer_acc.present?
        end
        column :vendor_acc do |row|
          "#{row.vendor_acc.name} ##{row.vendor_acc.id}" if row.vendor_acc.present?
        end
        column :customer_auth do |row|
          "#{row.customer_auth.name} ##{row.customer_auth.id}" if row.customer_auth.present?
        end
        column :orig_gw do |row|
          "#{row.orig_gw.name} ##{row.orig_gw.id}" if row.orig_gw.present?
        end
        column :sign_orig_transport_protocol
        column(:sign_orig_ip, sortable: 'sign_orig_ip') do |cdr|
          "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(':')
        end
        column(:sign_orig_local_ip, sortable: 'sign_orig_local_ip') do |cdr|
          "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(':')
        end
        column :auth_orig_transport_protocol
        column :auth_orig_ip do |cdr|
          "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(':')
        end
        column :term_gw do |row|
          "#{row.term_gw.name} ##{row.term_gw.id}" if row.term_gw.present?
        end
        column :sign_term_transport_protocol
        column(:sign_term_ip, sortable: :sign_term_ip) do |cdr|
          "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(':')
        end
        column(:sign_term_local_ip, sortable: 'sign_term_local_ip') do |cdr|
          "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(':')
        end
        column :is_redirected
        column :routing_delay
        column :pdd
        column :rtt
        column :early_media_present
        column('Status', sortable: 'success') do |cdr|
          cdr.status_sym.to_s
        end
        column :rateplan
        column :destination
        column :destination_rate_policy do |row|
          "#{row.destination_rate_policy.name} ##{row.destination_rate_policy.id}" if row.destination_rate_policy.present?
        end
        column :destination_fee
        column :destination_initial_interval
        column :destination_initial_rate
        column :destination_next_interval
        column :destination_next_rate
        column :customer_price
        column :routing_plan
        column :routing_group
        column :routing_tag
        column :dialpeer do |row|
          "Dialpeer ##{row.dialpeer.id}" if row.dialpeer.present?
        end
        column :dialpeer_fee
        column :dialpeer_initial_interval
        column :dialpeer_initial_rate
        column :dialpeer_next_interval
        column :dialpeer_next_rate
        column :vendor_price
        column :time_limit
        column :profit
        column :orig_call_id
        column :local_tag
        column :term_call_id
        column :customer_invoice_id
        column :vendor_invoice_id
        column :lega_rx_payloads
        column :lega_tx_payloads
        column :legb_rx_payloads
        column :legb_tx_payloads
        column :lega_rx_bytes
        column :lega_tx_bytes
        column :legb_rx_bytes
        column :legb_tx_bytes


      else
        logger.error "unknown csv_policy '#{policy}'"
        raise "unknown csv_policy '#{policy}'"
    end


  end

end
