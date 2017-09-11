ActiveAdmin.register Cdr::CdrArchive do
  menu parent: "CDR", priority: 99, label: "CDR Archive", if: proc { can?(:read, Cdr) }

  actions :index, :show
  config.batch_actions = false
  acts_as_cdr_stat

  before_filter do
    if params['q'].blank?
      params['q'] = {time_start_gteq: 3.days.ago} # only 3 last days by default
      flash.now[:notice] = "Only CDRs for last 3 days showed by default"
    else
      # fix this with right filter setup
      params['q']['account_id_eq'] = params['q']['account_id_eq'].to_i if params['q']['account_id_eq'].present?
      params['q']['disconnect_code_eq'] = params['q']['disconnect_code_eq'].to_i if params['q']['disconnect_code_eq'].present?
    end
  end

  controller do
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
            :pop,:node,:customer_auth,
            :customer,:vendor, :dump_level,
            :disconnect_initiator,:customer_acc, :vendor_acc,
            :orig_gw,:term_gw,
            :rateplan,:routing_group,
            :destination,:dialpeer,:destination_rate_policy,
            :dst_country,:dst_country
        )
      end
    end
  end

  scope :all, show_count: false
  scope :successful_calls, show_count: false
  scope :short_calls, show_count: false
  scope :rerouted_calls, show_count: false
  scope :no_rtp, show_count: false
  scope :not_authorized, show_count: false
  scope :bad_routing, show_count: false



  filter :id
  filter :time_start, as: :date_time_range
  filter :customer, collection: proc { Contractor.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :vendor, collection: proc { Contractor.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :customer_auth, collection: proc { CustomersAuth.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :src_prefix_routing
  filter :dst_prefix_routing
  filter :dst_country, input_html: {class: 'chosen'}
  filter :status, as: :select, collection: proc { [['FAILURE', false], ['SUCCESS', true]] }
  filter :duration
  filter :is_last_cdr, as: :select, collection: proc { [['Yes', true], ['No', false]] }

  filter :orig_gw, collection: proc { Gateway.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :term_gw, collection: proc { Gateway.select([:id, :name]).reorder(:name) }, input_html: {class: 'chosen'}
  filter :routing_plan, collection: proc { Routing::RoutingPlan.select([:id, :name]) }, input_html: {class: 'chosen'}
  filter :routing_group, collection: proc { RoutingGroup.select([:id, :name]) }, input_html: {class: 'chosen'}
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


  show do |cdr|
    panel "Attempts" do
      table_for cdr.attempts do
        column(:id) do |cdr|
          link_to cdr.id, resource_path(cdr), class: "resource_id_link"
        end
        column :time_start
        column :time_connect
        column :time_end



        column(:duration, class: "seconds") do |cdr|
          "#{cdr.duration} sec."
        end
        column("LegA DC") do |cdr|
          status_tag(cdr.lega_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.lega_disconnect_code==0 or cdr.lega_disconnect_code.nil?)
        end
        column("LegA Reason") do |cdr|
          cdr.lega_disconnect_reason #unless cdr.lega_disconnect_code==0
        end
        column("DC") do |cdr|
          status_tag(cdr.internal_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.internal_disconnect_code==0 or cdr.internal_disconnect_code.nil?)
        end
        column("Reason") do |cdr|
          cdr.internal_disconnect_reason #unless cdr.internal_disconnect_code==0
        end
        column("LegB DC") do |cdr|
          status_tag(cdr.legb_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.legb_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
        end
        column("LegB Reason") do |cdr|
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
        column :dst_prefix_in
        column :src_prefix_routing
        column :dst_prefix_routing
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

        column(:sign_orig_ip) do |cdr|
          "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(":")
        end
        column(:sign_orig_local_ip) do |cdr|
          "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(":")
        end


        column :auth_orig_ip do |cdr|
          "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(":")
        end

        column :term_gw
        column(:sign_term_ip) do |cdr|
          "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(":")
        end
        column(:sign_term_local_ip) do |cdr|
          "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(":")
        end
        column :routing_delay
        column :pdd
        column :rtt
        column :early_media_present
        column("Status") do |cdr|
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
        column :routing_plan
        column :routing_group
        column :dialpeer
        column :dialpeer_fee
        column :dialpeer_initial_interval
        column :dialpeer_initial_rate
        column :dialpeer_next_interval
        column :dialpeer_next_rate
        column :vendor_price
        column :time_limit
        column :profit
        column("Orig call") do |cdr|
          cdr.orig_call_id
        end
        column :local_tag
        column("Term call") do |cdr|
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
        column :uuid

      end if cdr.attempts.length > 0
    end

    tabs do
      tab :general_information do
        attributes_table do
          row :id
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
          row :dst_prefix_in
          row :src_prefix_routing
          row :dst_prefix_routing
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
          row :vendor
          row :customer_acc
          row :vendor_acc
          row :customer_auth
          row :orig_gw
          row :term_gw

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
          row :sign_orig_ip do
            "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(":")
          end

          row :sign_orig_local_ip do
            "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(":")
          end

          row :auth_orig_ip  do
            "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(":")
          end

          row :sign_term_ip do
            "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(":")
          end
          row :sign_term_local_ip do
            "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(":")
          end

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
        end

      end

      tab "Routing&Billing information" do
        attributes_table do
          row :customer_price
          row :vendor_price
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
        end
      end
    end
  end

  index do
    id_column

    column :time_start
    column :time_connect
    column :time_end




    column(:duration, sortable: 'duration', class: "seconds") do |cdr|
      "#{cdr.duration} sec."
    end
    column("LegA DC", sortable: 'lega_disconnect_code') do |cdr|
      status_tag(cdr.lega_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.lega_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
    end
    column("LegA Reason", sortable: 'lega_disconnect_reason') do |cdr|
      cdr.lega_disconnect_reason #unless cdr.lega_disconnect_code==0
    end
    column("DC", sortable: 'internal_disconnect_code') do |cdr|
      status_tag(cdr.internal_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.internal_disconnect_code==0 or cdr.internal_disconnect_code.nil?)
    end
    column("Reason", sortable: 'internal_disconnect_reason') do |cdr|
      cdr.internal_disconnect_reason #unless cdr.internal_disconnect_code==0
    end
    column("LegB DC", sortable: 'legb_disconnect_code') do |cdr|
      status_tag(cdr.legb_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.legb_disconnect_code==0 or cdr.legb_disconnect_code.nil?)
    end
    column("LegB Reason", sortable: 'legb_disconnect_reason') do |cdr|
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
    column :dst_prefix_in
    column :src_prefix_routing
    column :dst_prefix_routing
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


    column(:sign_orig_ip, sortable: 'sign_orig_ip') do |cdr|
      "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(":")
    end
    column(:sign_orig_local_ip, sortable: 'sign_orig_local_ip') do |cdr|
      "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(":")
    end
    column :auth_orig_ip do |cdr|
      "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(":")
    end
    column :term_gw

    column(:sign_term_ip, sortable: :sign_term_ip) do |cdr|
      "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(":")
    end
    column(:sign_term_local_ip, sortable: 'sign_term_local_ip') do |cdr|
      "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(":")
    end
    column :routing_delay
    column :pdd
    column :rtt
    column :early_media_present
    column("Status", sortable: 'success') do |cdr|
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
    column :routing_group
    column :dialpeer

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
    column :uuid
  end


  action_item :debug, only: :show do
    link_to('Debug', debug_cdr_path(resource))
  end

  # X-Accel-Redirect: /protected/iso.img;
  #  location /protected/ {
  #  internal;
  #  root   /some/path;
  #}
  member_action :dump, method: :get do
    file  = Cdr::CdrArchive.where(id: params[:id]).pluck(:dump_file).first
    if file.blank?
      raise ActiveRecord::RecordNotFound
    end
    response.headers['X-Accel-Redirect'] = "/dump/#{file.split("/").last}"
    head :ok
  end

  action_item :log_level_trace, only: :show do
    link_to("#{resource.log_level_name} trace", dump_cdr_path(resource)) if resource.has_dump?
  end


  member_action :debug, method: :get do

    @cdr = Cdr::CdrArchive.find(params[:id])
    redirect_to debug_call_path({routing_simulation: {
                                    remote_ip: @cdr.sign_orig_ip,
                                    remote_port: @cdr.sign_orig_port,
                                    src_prefix: @cdr.src_prefix_in,
                                    dst_prefix: @cdr.dst_prefix_in ,
                                    pop_id: @cdr.pop_id
                                }})
  end
end
