# frozen_string_literal: true

ActiveAdmin.register Cdr::Cdr, as: 'CDR' do
  menu parent: 'CDR', priority: 95, label: 'CDR history'

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'time_start_desc'
  acts_as_cdr_stat

  decorate_with CdrDecorator

  with_default_params do
    params[:q] = { time_start_gteq_datetime_picker: 0.days.ago.beginning_of_day }
    'Only CDRs started from beginning of the day showed by default'
  end

  before_action only: [:index] do
    if params['q'].present?
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
          :node,
          :pop,
          :lb_node
        )
      else
        super.preload(Cdr::Cdr::ADMIN_PRELOAD_LIST)
      end
    end
  end

  scope :all, show_count: false
  scope :successful_calls, show_count: false
  scope :short_calls, show_count: false
  scope :rerouted_calls, show_count: false
  scope :with_trace, show_count: false
  scope :not_authorized, show_count: false
  scope :bad_routing, show_count: false

  filter :id
  filter :routing_tag_ids_include,
         as: :select,
         collection: proc { tag_action_value_options },
         label: 'With routing tag',
         input_html: { class: 'chosen' }
  filter :time_start, as: :date_time_range

  contractor_filter :customer_id_eq, label: 'Customer', path_params: { q: { customer_eq: true } }
  account_filter :customer_acc_id_eq, label: 'Customer account'

  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }
  account_filter :vendor_acc_id_eq, label: 'Vendor account'

  filter :customer_auth, collection: proc { CustomersAuth.select(%i[id name]).reorder(:name) }, input_html: { class: 'chosen' }
  filter :src_prefix_routing, filters: %i[equals contains starts_with ends_with]
  filter :src_area, collection: proc { Routing::Area.select(%i[id name]) }, input_html: { class: 'chosen' }
  filter :dst_prefix_routing, filters: %i[equals contains starts_with ends_with]
  filter :dst_area, collection: proc { Routing::Area.select(%i[id name]) }, input_html: { class: 'chosen' }

  country_filter :src_country_id_eq, label: 'SRC Country'
  network_filter :src_network_id_eq, label: 'SRC Network'

  country_filter :dst_country_id_eq, label: 'DST Country'
  network_filter :dst_network_id_eq, label: 'DST Network'

  filter :status, as: :select, collection: proc { [['FAILURE', false], ['SUCCESS', true]] }
  filter :duration
  filter :is_last_cdr, as: :select, collection: proc { [['Yes', true], ['No', false]] }

  filter :dump_level_id_eq, label: 'Dump level', as: :select,
                            collection: Cdr::Cdr::DUMP_LEVELS.invert
  filter :disconnect_initiator_id_eq, label: 'Disconnect initiator', as: :select,
                                      collection: Cdr::Cdr::DISCONNECT_INITIATORS.invert

  filter :orig_gw_id_eq,
         as: :select,
         label: 'Orig GW',
         collection: proc {
           resource_id = params.fetch(:q, {})[:orig_gw_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         },
         input_html: {
           class: 'chosen-ajax',
           'data-path': '/gateways/search?q[allow_origination_eq]=true&q[ordered_by]=name'
         }

  filter :term_gw_id_eq,
         as: :select,
         label: 'Term GW',
         collection: proc {
           resource_id = params.fetch(:q, {})[:term_gw_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         },
         input_html: {
           class: 'chosen-ajax',
           'data-path': '/gateways/search?q[allow_termination_eq]=true&q[ordered_by]=name'
         }

  filter :routing_plan, collection: proc { Routing::RoutingPlan.select(%i[id name]) }, input_html: { class: 'chosen' }
  filter :routing_group, collection: proc { Routing::RoutingGroup.select(%i[id name]) }, input_html: { class: 'chosen' }
  filter :rateplan, collection: proc { Routing::Rateplan.select(%i[id name]) }, input_html: { class: 'chosen' }

  filter :internal_disconnect_code
  filter :internal_disconnect_reason, filters: %i[equals contains starts_with ends_with]
  filter :lega_disconnect_code
  filter :lega_disconnect_reason, filters: %i[equals contains starts_with ends_with]
  filter :lega_q850_cause_eq, label: 'LegA Q.850 cause', as: :select, collection: System::Q850::CAUSES.invert, input_html: { class: 'chosen' }

  filter :legb_disconnect_code
  filter :legb_disconnect_reason, filters: %i[equals contains starts_with ends_with]
  filter :legb_q850_cause_eq, label: 'LegB Q.850 cause', as: :select, collection: System::Q850::CAUSES.invert, input_html: { class: 'chosen' }

  filter :src_prefix_in, as: :string_eq
  filter :dst_prefix_in, as: :string_eq
  filter :src_prefix_out, filters: %i[equals contains starts_with ends_with]
  filter :dst_prefix_out, filters: %i[equals contains starts_with ends_with]
  filter :lrn, filters: %i[equals contains starts_with ends_with]
  filter :diversion_in, as: :string_eq
  filter :diversion_out, as: :string_eq
  filter :src_name_in, as: :string_eq
  filter :src_name_out, as: :string_eq
  filter :node, input_html: { class: 'chosen' }
  filter :pop, input_html: { class: 'chosen' }
  filter :local_tag, filters: %i[equals contains starts_with ends_with]
  filter :legb_local_tag, filters: %i[equals contains starts_with ends_with]
  filter :orig_call_id, as: :string, filters: %i[equals contains starts_with ends_with]
  filter :term_call_id, as: :string, filters: %i[equals contains starts_with ends_with]
  filter :routing_attempt
  filter :customer_price
  filter :vendor_price
  filter :routing_delay
  filter :pdd
  filter :rtt
  filter :p_charge_info_in, as: :string_eq
  filter :uuid_equals, label: 'UUID'
  filter :auth_orig_ip_covers,
         as: :string,
         input_html: { class: 'search_filter_string' },
         label: I18n.t('activerecord.attributes.cdr.auth_orig_ip')
  filter :sign_orig_ip, filters: %i[equals contains starts_with ends_with]
  filter :sign_orig_local_ip, filters: %i[equals contains starts_with ends_with]
  filter :sign_term_local_ip, filters: %i[equals contains starts_with ends_with]
  filter :sign_term_ip, filters: %i[equals contains starts_with ends_with]
  filter :customer_auth_external_type_eq, as: :string, label: 'CUSTOMER AUTH EXTERNAL TYPE'

  acts_as_filter_by_routing_tag_ids routing_tag_ids_covers: false

  # X-Accel-Redirect: /protected/iso.img;
  #  location /protected/ {
  #  internal;
  #  root   /some/path;
  # }
  member_action :dump, method: :get do
    file = resource.dump_filename
    raise ActiveRecord::RecordNotFound if file.blank?

    response.headers['X-Accel-Redirect'] = file
    head 200
  end

  member_action :download_call_record_lega, method: :get do
    file = resource.call_record_filename_lega
    raise ActiveRecord::RecordNotFound if file.blank?

    response.headers['X-Accel-Redirect'] = file
    head 200
  end

  member_action :download_call_record_legb, method: :get do
    file = resource.call_record_filename_legb
    raise ActiveRecord::RecordNotFound if file.blank?

    response.headers['X-Accel-Redirect'] = file
    head 200
  end

  member_action :routing_simulation, method: :get do
    # proto = UDP if no info in DB
    proto = resource.auth_orig_transport_protocol_id.nil? ? 1 : resource.auth_orig_transport_protocol_id
    redirect_to routing_simulation_path(
      anchor: 'detailed',
      routing_simulation: {
        auth_id: resource.customer_auth&.require_incoming_auth ? resource.orig_gw_id : nil,
        transport_protocol_id: proto,
        remote_ip: resource.auth_orig_ip,
        remote_port: resource.auth_orig_port,
        src_number: resource.src_prefix_in,
        dst_number: resource.dst_prefix_in,
        pop_id: resource.pop_id,
        x_yeti_auth: resource.customer_auth&.x_yeti_auth&.first,
        uri_domain: resource.ruri_domain,
        from_domain: resource.from_domain,
        to_domain: resource.to_domain,
        pai: resource.pai_in,
        ppi: resource.ppi_in,
        privacy: resource.privacy_in,
        rpid: resource.rpid_in,
        rpid_privacy: resource.rpid_privacy_in
      }
    )
  end

  action_item :lega_rtp_rx_streams, only: :show do
    link_to('LegA RX RTP Streams', rtp_rx_streams_path(q: { local_tag_equals: resource.local_tag, time_start_gteq: resource.time_start - 60, time_start_lteq: resource.time_start + 60 }))
  end
  action_item :lega_rtp_tx_streams, only: :show do
    link_to('LegA TX RTP Streams', rtp_tx_streams_path(q: { local_tag_equals: resource.local_tag, time_start_gteq: resource.time_start - 60, time_start_lteq: resource.time_start + 60 }))
  end
  action_item :legb_rtp_rx_streams, only: :show do
    link_to('LegB RX RTP Streams', rtp_rx_streams_path(q: { local_tag_equals: resource.legb_local_tag, time_start_gteq: resource.time_start - 60, time_start_lteq: resource.time_start + 60 }))
  end
  action_item :legb_rtp_tx_streams, only: :show do
    link_to('LegB TX RTP Streams', rtp_tx_streams_path(q: { local_tag_equals: resource.legb_local_tag, time_start_gteq: resource.time_start - 60, time_start_lteq: resource.time_start + 60 }))
  end

  action_item :routing_simulation, only: :show do
    link_to('Routing simulation', routing_simulation_cdr_path(resource))
  end

  action_item :log_level_trace, only: :show do
    link_to("#{resource.dump_level_name} trace", dump_cdr_path(resource)) if resource.has_dump?
  end

  action_item :call_record_lega, only: :show do
    link_to('Call record LegA', download_call_record_lega_cdr_path(resource)) if resource.audio_recorded?
  end

  action_item :call_record_lega, only: :show do
    link_to('Call record LegB', download_call_record_legb_cdr_path(resource)) if resource.audio_recorded?
  end

  action_item :download_csv, only: :index do
    dropdown_menu 'Download CSV' do
      _cdrs_params = params.to_unsafe_h.deep_symbolize_keys.slice(:q, :order, :scope)
                           .merge(format: :csv)
      item(
        'Full CSV', cdrs_path(csv_policy: 'all', **_cdrs_params)
      )
      item(
        'CSV for Customer leg',
        cdrs_path(csv_policy: 'customer', **_cdrs_params.deep_merge(q: { is_last_cdr_eq: true }))
      )
      item(
        'CSV for Vendor leg',
        cdrs_path(csv_policy: 'vendor', **_cdrs_params)
      )
    end
  end

  show do |cdr|
    panel 'Attempts' do
      unless cdr.attempts.empty?
        scope = cdr.attempts.preload(Cdr::Cdr::ADMIN_PRELOAD_LIST)
        records = CdrDecorator.decorate_collection(scope.to_a)
        table_for records do
          column(:id) do |cdr_attempt|
            link_to cdr_attempt.id, resource_path(cdr_attempt), class: 'resource_id_link'
          end
          column :time_start
          column :time_connect
          column :time_end

          column(:duration, class: 'seconds') do |cdr_attempt|
            "#{cdr_attempt.duration} sec."
          end
          column('LegA DC') do |cdr_attempt|
            status_tag(cdr_attempt.lega_disconnect_code.to_s, class: cdr_attempt.success? ? :ok : :red) unless (cdr_attempt.lega_disconnect_code == 0) || cdr_attempt.lega_disconnect_code.nil?
            status_tag("q850: #{cdr.lega_q850_cause}", class: cdr.success? ? :ok : :red) unless cdr.lega_q850_cause.nil?
          end
          column('LegA Reason', &:lega_disconnect_reason)
          column('DC') do |cdr_attempt|
            status_tag(cdr_attempt.internal_disconnect_code.to_s, class: cdr_attempt.success? ? :ok : :red) unless (cdr_attempt.internal_disconnect_code == 0) || cdr_attempt.internal_disconnect_code.nil?
          end
          column('Reason') do |cdr|
            if cdr.internal_disconnect_code_id.nil?
              cdr.internal_disconnect_reason
            else
              link_to(cdr.internal_disconnect_code_id, disconnect_code_path(cdr.internal_disconnect_code_id)) + ' ' + cdr.internal_disconnect_reason
            end
          end
          column('LegB DC') do |cdr_attempt|
            status_tag(cdr_attempt.legb_disconnect_code.to_s, class: cdr_attempt.success? ? :ok : :red) unless (cdr_attempt.legb_disconnect_code == 0) || cdr_attempt.legb_disconnect_code.nil?
            status_tag("q850: #{cdr.legb_q850_cause}", class: cdr.success? ? :ok : :red) unless cdr.legb_q850_cause.nil?
          end
          column('LegB Reason', &:legb_disconnect_reason)
          column :disconnect_initiator, &:disconnect_initiator_name
          column :routing_attempt do |cdr_attempt|
            status_tag(cdr_attempt.routing_attempt.to_s, class: cdr_attempt.is_last_cdr? ? :ok : nil)
          end
          column :lega_reason
          column :legb_reason
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

          column :src_country
          column :src_network
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

          column(:sign_orig_ip) do |cdr_attempt|
            "#{cdr_attempt.sign_orig_ip}:#{cdr_attempt.sign_orig_port}".chomp(':')
          end
          column(:sign_orig_local_ip) do |cdr_attempt|
            "#{cdr_attempt.sign_orig_local_ip}:#{cdr_attempt.sign_orig_local_port}".chomp(':')
          end

          column :auth_orig_transport_protocol
          column :auth_orig_ip do |cdr_attempt|
            "#{cdr_attempt.auth_orig_ip}:#{cdr_attempt.auth_orig_port}".chomp(':')
          end

          column :term_gw
          column :legb_ruri
          column :legb_outbound_proxy
          column :sign_term_transport_protocol
          column(:sign_term_ip) do |cdr_attempt|
            "#{cdr_attempt.sign_term_ip}:#{cdr_attempt.sign_term_port}".chomp(':')
          end
          column(:sign_term_local_ip) do |cdr_attempt|
            "#{cdr_attempt.sign_term_local_ip}:#{cdr_attempt.sign_term_local_port}".chomp(':')
          end
          column :is_redirected

          column :routing_delay, &:decorated_routing_delay
          column :pdd, &:decorated_pdd
          column :rtt, &:decorated_rtt

          column :early_media_present
          column('Status') do |cdr_attempt|
            status_tag(cdr_attempt.status_sym.to_s, class: cdr_attempt.success? ? :ok : nil)
          end
          column :rateplan
          column :destination
          column :destination_rate_policy, &:destination_rate_policy_name
          column :destination_fee

          column('Destination rates', sortable: 'destination_next_rate') do |cdr|
            "#{cdr.destination_initial_rate}/#{cdr.destination_next_rate}".chomp('/')
          end
          column('Destination intervals', sortable: 'destination_next_interval') do |cdr|
            "#{cdr.destination_initial_interval}/#{cdr.destination_next_interval}".chomp('/')
          end

          column :customer_price
          column :customer_price_no_vat
          column :customer_duration
          column :routing_plan
          column :routing_group
          column :routing_tags
          column :dialpeer
          column :dialpeer_fee

          column('Dialpeer rates', sortable: 'dialpeer_next_rate') do |cdr|
            "#{cdr.dialpeer_initial_rate}/#{cdr.dialpeer_next_rate}".chomp('/')
          end
          column('Dialpeer intervals', sortable: 'dialpeer_next_interval') do |cdr|
            "#{cdr.dialpeer_initial_interval}/#{cdr.dialpeer_next_interval}".chomp('/')
          end

          column :vendor_price
          column :vendor_duration
          column :time_limit
          column :profit
          column('Orig call', &:orig_call_id)
          column :local_tag
          column :legb_local_tag
          column('Term call', &:term_call_id)

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

          column :p_charge_info_in

          column :core_version
          column :yeti_version
          column :lega_user_agent
          column :legb_user_agent
          column :uuid

          column :failed_resource_type_id
          column :failed_resource_id

          column :customer_external_id
          column :customer_auth_external_id
          column :customer_auth_external_type
          column :customer_acc_vat
          column :customer_acc_external_id

          column :vendor_external_id
          column :vendor_acc_external_id
          column :orig_gw_external_id
          column :term_gw_external_id
        end
      end
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
            status_tag(cdr.status_sym.to_s, class: cdr.success? ? :ok : nil)
          end
          row :disconnect_initiator, &:disconnect_initiator_name
          row :lega_disconnect_code
          row :lega_disconnect_reason
          row :internal_disconnect_code
          row :internal_disconnect_reason do |cdr|
            if cdr.internal_disconnect_code_id.nil?
              cdr.internal_disconnect_reason
            else
              link_to(cdr.internal_disconnect_code_id, disconnect_code_path(cdr.internal_disconnect_code_id)) + ' ' + cdr.internal_disconnect_reason
            end
          end
          row :legb_disconnect_code
          row :legb_disconnect_reason

          row :lega_q850_cause do |cdr|
            System::Q850::CAUSES[cdr.lega_q850_cause] || cdr.lega_q850_cause
          end
          row :lega_q850_text
          row :lega_q850_params
          row :legb_q850_cause do |cdr|
            System::Q850::CAUSES[cdr.legb_q850_cause] || cdr.legb_q850_cause
          end
          row :legb_q850_text
          row :legb_q850_params

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

          row :src_country
          row :src_network
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
            "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(':')
          end

          row :sign_orig_local_ip do
            "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(':')
          end

          row :auth_orig_transport_protocol
          row :auth_orig_ip do
            "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(':')
          end

          row :legb_ruri
          row :legb_outbound_proxy
          row :sign_term_transport_protocol
          row :sign_term_ip do
            "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(':')
          end
          row :sign_term_local_ip do
            "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(':')
          end

          row :is_redirected

          row :p_charge_info_in

          row :local_tag
          row :legb_local_tag
          row :routing_delay
          row :pdd
          row :rtt
          row :early_media_present
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
          row :destination_rate_policy, &:destination_rate_policy_name
          row :destination_fee
          row :destination_initial_interval
          row :destination_initial_rate
          row :destination_next_interval
          row :destination_next_rate

          row :routing_plan
          row :routing_group
          row :routing_tags
          row :dialpeer

          row :dialpeer_fee
          row :dialpeer_initial_interval
          row :dialpeer_initial_rate
          row :dialpeer_next_interval
          row :dialpeer_next_rate

          row :time_limit
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
      tab :identity do
        attributes_table do
          row :lega_identity
          row :lega_ss_status
          row :legb_ss_status
        end
      end
    end
  end

  index do
    column :id do |cdr|
      if cdr.has_dump?
        link_to(cdr.id, resource_path(cdr), class: 'resource_id_link', title: 'Details') + ' ' + link_to(fa_icon('exchange'), dump_cdr_path(cdr), title: 'Download trace')
      else
        link_to(cdr.id, resource_path(cdr), class: 'resource_id_link', title: 'Details')
      end
    end

    column :time_start
    column :time_connect
    column :time_end

    column(:duration, sortable: 'duration', class: 'seconds') do |cdr|
      "#{cdr.duration} sec."
    end
    column('LegA DC', sortable: 'lega_disconnect_code') do |cdr|
      status_tag(cdr.lega_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.lega_disconnect_code == 0) || cdr.legb_disconnect_code.nil?
      status_tag("q850: #{cdr.lega_q850_cause}", class: cdr.success? ? :ok : :red) unless cdr.lega_q850_cause.nil?
    end
    column('LegA Reason', sortable: 'lega_disconnect_reason', &:lega_disconnect_reason)
    column('DC', sortable: 'internal_disconnect_code') do |cdr|
      status_tag(cdr.internal_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.internal_disconnect_code == 0) || cdr.internal_disconnect_code.nil?
    end
    column('Reason', sortable: 'internal_disconnect_reason') do |cdr|
      if cdr.internal_disconnect_code_id.nil?
        cdr.internal_disconnect_reason
      else
        link_to(cdr.internal_disconnect_code_id, disconnect_code_path(cdr.internal_disconnect_code_id)) + ' ' + cdr.internal_disconnect_reason
      end
    end
    column('LegB DC', sortable: 'legb_disconnect_code') do |cdr|
      status_tag(cdr.legb_disconnect_code.to_s, class: cdr.success? ? :ok : :red) unless (cdr.legb_disconnect_code == 0) || cdr.legb_disconnect_code.nil?
      status_tag("q850: #{cdr.legb_q850_cause}", class: cdr.success? ? :ok : :red) unless cdr.legb_q850_cause.nil?
    end
    column('LegB Reason', sortable: 'legb_disconnect_reason', &:legb_disconnect_reason)
    column :disconnect_initiator, &:disconnect_initiator_name
    column :routing_attempt do |cdr|
      status_tag(cdr.routing_attempt.to_s, class: cdr.is_last_cdr? ? :ok : nil)
    end

    # column :routing_attempt
    # column :is_last_cdr

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

    column :src_country
    column :src_network
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
        "#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(':')
      else
        "#{cdr.sign_orig_transport_protocol.name}://#{cdr.sign_orig_ip}:#{cdr.sign_orig_port}".chomp(':')
      end
    end
    column('LegA local socket', sortable: 'sign_orig_local_ip') do |cdr|
      "#{cdr.sign_orig_local_ip}:#{cdr.sign_orig_local_port}".chomp(':')
    end
    column('LegA originator address', sotrable: 'auth_orig_ip') do |cdr|
      if cdr.auth_orig_transport_protocol_id.nil?
        "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(':')
      else
        "#{cdr.auth_orig_transport_protocol.name}://#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(':')
      end
    end
    column :term_gw
    column :legb_ruri
    column :legb_outbound_proxy
    column('LegB remote socket', sortable: :sign_term_ip) do |cdr|
      if cdr.sign_term_transport_protocol_id.nil?
        "#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(':')
      else
        "#{cdr.sign_term_transport_protocol.name}://#{cdr.sign_term_ip}:#{cdr.sign_term_port}".chomp(':')
      end
    end
    column('LegB local socket', sortable: 'sign_term_local_ip') do |cdr|
      "#{cdr.sign_term_local_ip}:#{cdr.sign_term_local_port}".chomp(':')
    end
    column :is_redirected

    column :routing_delay, &:decorated_routing_delay
    column :pdd, &:decorated_pdd
    column :rtt, &:decorated_rtt

    column :early_media_present
    column('Status', sortable: 'success') do |cdr|
      status_tag(cdr.status_sym.to_s, class: cdr.success? ? :ok : nil)
    end
    column :rateplan
    column :destination
    column :destination_rate_policy, &:destination_rate_policy_name
    column :destination_fee

    column('Destination rates', sortable: 'destination_next_rate') do |cdr|
      "#{cdr.destination_initial_rate}/#{cdr.destination_next_rate}".chomp('/')
    end
    column('Destination intervals', sortable: 'destination_next_interval') do |cdr|
      "#{cdr.destination_initial_interval}/#{cdr.destination_next_interval}".chomp('/')
    end

    column :customer_price
    column :customer_acc_vat
    column :customer_price_no_vat
    column :customer_duration
    column :routing_plan
    column :routing_group
    column :routing_tags
    column :dialpeer

    column :dialpeer_fee
    column('Dialpeer rates', sortable: 'dialpeer_next_rate') do |cdr|
      "#{cdr.dialpeer_initial_rate}/#{cdr.dialpeer_next_rate}".chomp('/')
    end
    column('Dialpeer intervals', sortable: 'dialpeer_next_interval') do |cdr|
      "#{cdr.dialpeer_initial_interval}/#{cdr.dialpeer_next_interval}".chomp('/')
    end

    column :vendor_price
    column :vendor_duration
    column :time_limit
    column :profit
    column :orig_call_id
    column :local_tag
    column :legb_local_tag
    column :term_call_id

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

    column :p_charge_info_in

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
      column :legb_local_tag
      column('LegA DC', sortable: 'lega_disconnect_code') do |cdr|
        cdr.lega_disconnect_code.to_s unless (cdr.lega_disconnect_code == 0) || cdr.legb_disconnect_code.nil?
      end
      column('LegA Reason', sortable: 'lega_disconnect_reason', &:lega_disconnect_reason)
      column :auth_orig_transport_protocol
      column :auth_orig_ip do |cdr|
        "#{cdr.auth_orig_ip}:#{cdr.auth_orig_port}".chomp(':')
      end
      column :src_prefix_routing
      column :dst_prefix_routing
      column :destination_prefix

      column :p_charge_info_in

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
        cdr.legb_disconnect_code.to_s unless (cdr.legb_disconnect_code == 0) || cdr.legb_disconnect_code.nil?
      end
      column('LegB Reason', sortable: 'legb_disconnect_reason', &:legb_disconnect_reason)

      column :pdd
      column :rtt
      column :early_media_present

    else # all or not defined policy
      column :id
      column :time_start
      column :time_connect
      column :time_end
      column(:duration, sortable: 'duration', class: 'seconds') do |cdr|
        "#{cdr.duration} sec."
      end
      column('LegA DC', sortable: 'lega_disconnect_code') do |cdr|
        cdr.lega_disconnect_code.to_s unless (cdr.lega_disconnect_code == 0) || cdr.legb_disconnect_code.nil?
      end
      column('LegA Reason', sortable: 'lega_disconnect_reason', &:lega_disconnect_reason)
      column('DC', sortable: 'internal_disconnect_code') do |cdr|
        cdr.internal_disconnect_code.to_s unless (cdr.internal_disconnect_code == 0) || cdr.internal_disconnect_code.nil?
      end
      column('Reason', sortable: 'internal_disconnect_reason', &:internal_disconnect_reason)
      column('LegB DC', sortable: 'legb_disconnect_code') do |cdr|
        cdr.legb_disconnect_code.to_s unless (cdr.legb_disconnect_code == 0) || cdr.legb_disconnect_code.nil?
      end
      column('LegB Reason', sortable: 'legb_disconnect_reason', &:legb_disconnect_reason)
      column :disconnect_initiator, &:disconnect_initiator_name
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
      column :src_country
      column :src_network
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
      column :destination_rate_policy, &:destination_rate_policy_name
      column :destination_fee
      column :destination_initial_interval
      column :destination_initial_rate
      column :destination_next_interval
      column :destination_next_rate
      column :customer_price
      column :routing_plan
      column :routing_group
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
      column :legb_local_tag
      column :term_call_id
    end
  end
end
