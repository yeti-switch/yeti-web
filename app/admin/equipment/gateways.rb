# frozen_string_literal: true

ActiveAdmin.register Gateway do
  menu parent: 'Equipment', priority: 75
  search_support!
  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status
  acts_as_stat
  acts_as_quality_stat
  acts_as_lock GatewayQualityCheck
  acts_as_stats_actions
  acts_as_async_destroy('Gateway')
  acts_as_async_update BatchUpdateForm::Gateway

  acts_as_good_job_lock

  decorate_with GatewayDecorator

  acts_as_export :id, :uuid, :name, :enabled,
                 [:scheduler_name, proc { |row| row.scheduler.try(:name) }],
                 [:gateway_group_name, proc { |row| row.gateway_group.try(:name) }],
                 :priority,
                 :weight,
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 [:contractor_name, proc { |row| row.contractor.try(:name) }],
                 :is_shared,
                 :allow_origination, :allow_termination, :sst_enabled,
                 :origination_capacity, :termination_capacity, :termination_subscriber_capacity,
                 :termination_cps_limit, :termination_cps_wsize,
                 :termination_subscriber_cps_limit, :termination_subscriber_cps_wsize,
                 :preserve_anonymous_from_domain,
                 [:termination_src_numberlist_name, proc { |row| row.termination_src_numberlist.try(:name) }],
                 [:termination_dst_numberlist_name, proc { |row| row.termination_dst_numberlist.try(:name) }],
                 :acd_limit, :asr_limit, :short_calls_limit,
                 :sst_session_expires, :sst_minimum_timer, :sst_maximum_timer,
                 [:session_refresh_method_name, proc { |row| row.session_refresh_method.try(:name) }],
                 :sst_accept501,
                 [:sensor_level_name, proc { |row| row.sensor_level.try(:name) }],
                 [:sensor_name, proc { |row| row.sensor.try(:name) }],
                 :orig_next_hop,
                 :orig_append_headers_req,
                 :orig_use_outbound_proxy, :orig_force_outbound_proxy,
                 [:orig_proxy_transport_protocol_name, proc { |row| row.orig_proxy_transport_protocol.try(:name) }],
                 :orig_outbound_proxy,
                 :dialog_nat_handling, # :transparent_dialog_id,
                 :force_cancel_routeset,
                 [:orig_disconnect_policy_name, proc { |row| row.orig_disconnect_policy.try(:name) }],
                 [:transport_protocol_name, proc { |row| row.transport_protocol.try(:name) }],
                 :sip_schema_name,
                 :host,
                 :port,
                 :registered_aor_mode_name,
                 [:network_protocol_priority_name, proc { |row| row.network_protocol_priority.try(:name) }],
                 :resolve_ruri,
                 [:diversion_send_mode_name, proc { |row| row.diversion_send_mode.try(:name) }],
                 :diversion_domain,
                 :diversion_rewrite_rule, :diversion_rewrite_result,
                 :pai_send_mode_name,
                 :pai_domain,
                 :src_name_rewrite_rule, :src_name_rewrite_result,
                 :src_rewrite_rule, :src_rewrite_result,
                 :dst_rewrite_rule, :dst_rewrite_result,
                 :to_rewrite_rule, :to_rewrite_result,
                 [:lua_script_name, proc { |row| row.lua_script.try(:name) }],
                 :auth_enabled, :auth_from_user, :auth_from_domain,
                 :term_use_outbound_proxy, :term_force_outbound_proxy,
                 [:term_proxy_transport_protocol_name, proc { |row| row.term_proxy_transport_protocol.try(:name) }],
                 :term_outbound_proxy,
                 :term_next_hop_for_replies, :term_next_hop,
                 [:term_disconnect_policy_name, proc { |row| row.term_disconnect_policy.try(:name) }],
                 :term_append_headers_req,
                 [:sdp_alines_filter_type_name, proc { |row| row.sdp_alines_filter_type.try(:name) }],
                 :sdp_alines_filter_list,
                 :ringing_timeout,
                 :relay_options, :relay_reinvite, :relay_hold,
                 :relay_prack,
                 [:rel100_mode_name, proc { |row| row.rel100_mode.try(:name) }],
                 :relay_update,
                 :allow_1xx_without_to_tag,
                 :sip_timer_b, :dns_srv_failover_timer,
                 [:sdp_c_location_name, proc { |row| row.sdp_c_location.try(:name) }],
                 [:codec_group_name, proc { |row| row.codec_group.try(:name) }],
                 :proxy_media, :single_codec_in_200ok, :force_symmetric_rtp, :symmetric_rtp_nonstop,
                 :force_dtmf_relay, :rtp_ping,
                 :rtp_timeout,
                 :filter_noaudio_streams,
                 :rtp_relay_timestamp_aligning,
                 :rtp_force_relay_cn,
                 [:dtmf_send_mode_name, proc { |row| row.dtmf_send_mode.try(:name) }],
                 [:dtmf_receive_mode_name, proc { |row| row.dtmf_receive_mode.try(:name) }],
                 [:rx_inband_dtmf_filtering_mode, proc { |row| row.rx_inband_dtmf_filtering_mode.try(:name) }],
                 [:tx_inband_dtmf_filtering_mode, proc { |row| row.tx_inband_dtmf_filtering_mode.try(:name) }],
                 [:media_encryption_mode, proc { |row| row.media_encryption_mode.try(:name) }],
                 :ice_mode_name, :rtcp_mux_mode_name, :rtcp_feedback_mode_name,
                 :suppress_early_media,
                 :send_lnp_information,
                 :force_one_way_early_media, :max_30x_redirects,
                 :privacy_mode_name,
                 :stir_shaken_mode_name,
                 [:stir_shaken_crt_name, proc { |row| row.stir_shaken_crt.try(:name) }],
                 :dump_level_name

  acts_as_import resource_class: Importing::Gateway

  scope :locked
  scope :shared
  scope :with_radius_accounting
  scope :with_dump
  scope :scheduled

  includes :contractor, :gateway_group, :pop, :statistic, :diversion_send_mode,
           :session_refresh_method, :codec_group,
           :term_disconnect_policy, :orig_disconnect_policy,
           :sdp_c_location, :sdp_alines_filter_type,
           :sensor, :sensor_level,
           :dtmf_send_mode, :dtmf_receive_mode,
           :radius_accounting_profile,
           :transport_protocol, :term_proxy_transport_protocol, :orig_proxy_transport_protocol,
           :rel100_mode, :rx_inband_dtmf_filtering_mode, :tx_inband_dtmf_filtering_mode,
           :network_protocol_priority, :media_encryption_mode,
           :termination_src_numberlist, :termination_dst_numberlist, :lua_script, :stir_shaken_crt,
           :throttling_profile, :scheduler

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.name.underscore.to_sym].permit!]
    end
  end

  before_action only: [:show] do
    @registrations = Yeti::RpcCalls::IncomingRegistrations.call Node.all, auth_id: resource.id
    @registrations.data.map! { |row| RealtimeData::IncomingRegistration.new(row) }
    flash.now[:warning] = @registrations.errors if @registrations.errors.any?
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :enabled
    column :locked

    column :contractor do |c|
      auto_link(c.contractor, c.contractor.decorated_display_name)
    end
    column :is_shared
    column :gateway_group
    column :priority
    column :weight
    column :pop

    column :transport_protocol
    column :host, sortable: 'host' do |gw|
      gw.use_registered_aor? ? status_tag('Dynamic AOR', class: :ok) : "#{gw.host}:#{gw.port}".chomp(':')
    end
    column :network_protocol_priority

    column :allow_termination
    column :allow_origination

    column :origination_capacity
    column :termination_capacity

    column :calls, sortable: 'gateways_stats.calls' do |row|
      row.statistic.try(:calls)
    end
    column :total_duration, sortable: 'gateways_stats.total_duration' do |row|
      "#{row.statistic.try(:total_duration) || 0} sec."
    end

    column :asr, sortable: 'gateways_stats.asr' do |row|
      row.statistic.try(:asr)
    end
    column :asr_limit

    column :acd, sortable: 'gateways_stats.acd' do |row|
      row.statistic.try(:acd)
    end
    column :acd_limit
    column :short_calls_limit

    column :preserve_anonymous_from_domain
    column :termination_src_numberlist
    column :termination_dst_numberlist

    # SST
    column :sst_enabled
    column :sst_session_expires
    column :sst_minimum_timer
    column :sst_maximum_timer
    column :session_refresh_method
    column :sst_accept501

    # SENSOR
    column :sensor
    column :sensor_level

    # SIGNALING
    column :relay_options
    column :relay_reinvite
    column :relay_prack
    column :rel100_mode
    column :relay_update
    column :transit_headers_from_origination
    column :transit_headers_from_termination
    column :sip_interface_name

    column :orig_next_hop
    column :orig_append_headers_req
    column :orig_use_outbound_proxy
    column :orig_force_outbound_proxy
    column :orig_proxy_transport_protocol
    column :orig_outbound_proxy
    column :transparent_dialog_id
    column :dialog_nat_handling
    column :orig_disconnect_policy

    column :resolve_ruri

    column :term_use_outbound_proxy
    column :term_force_outbound_proxy
    column :term_proxy_transport_protocol
    column :term_outbound_proxy
    column :term_next_hop
    column :term_next_hop_for_replies
    column :term_disconnect_policy
    column :term_append_headers_req
    column :sdp_alines_filter_type
    column :sdp_alines_filter_list
    column :ringing_timeout
    column :allow_1xx_without_to_tag
    column :max_30x_redirects
    column :max_transfers
    column :sip_timer_b
    column :dns_srv_failover_timer
    column :suppress_early_media
    column :fake_180_timer
    column :send_lnp_information

    # TRANSLATIONS
    # disabling to improve performance of index page rendering
    # column :diversion_send_mode
    # column :diversion_domain
    # column :diversion_rewrite_rule
    # column :diversion_rewrite_result
    # column :src_name_rewrite_rule
    # column :src_name_rewrite_result
    # column :src_rewrite_rule
    # column :src_rewrite_result
    # column :dst_rewrite_rule
    # column :dst_rewrite_result
    column :lua_script

    # MEDIA
    column :sdp_c_location
    column :codec_group
    column :proxy_media
    column :single_codec_in_200ok
    column :force_symmetric_rtp
    column :symmetric_rtp_nonstop
    column :rtp_ping
    column :rtp_timeout
    column :filter_noaudio_streams
    column :rtp_relay_timestamp_aligning
    column :rtp_force_relay_cn
    column :force_one_way_early_media
    column :rtp_interface_name
    column :media_encryption_mode
    ## DTMF
    column :force_dtmf_relay
    column :dtmf_send_mode
    column :dtmf_receive_mode
    column :rx_inband_dtmf_filtering_mode
    column :tx_inband_dtmf_filtering_mode
    # #RADIUS
    column :radius_accounting_profile
    column :external_id
  end

  filter :id
  filter :uuid
  filter :name
  contractor_filter :contractor_id_eq

  association_ajax_filter :gateway_group_id_eq,
                          label: 'Gateway Group',
                          scope: -> { GatewayGroup.order(:name) },
                          path: '/gateway_groups/search'

  filter :pop, input_html: { class: 'chosen' }
  filter :transport_protocol
  filter :host
  filter :enabled, as: :select, collection: [['Yes', true], ['No', false]]
  filter :allow_origination, as: :select, collection: [['Yes', true], ['No', false]]
  filter :allow_termination, as: :select, collection: [['Yes', true], ['No', false]]
  filter :proxy_media, as: :select, collection: [['Yes', true], ['No', false]]

  filter :statistic_calls, as: :numeric
  filter :statistic_total_duration, as: :numeric
  filter :statistic_asr, as: :numeric
  filter :statistic_acd, as: :numeric
  filter :external_id
  filter :radius_accounting_profile, input_html: { class: 'chosen' }
  filter :lua_script, input_html: { class: 'chosen' }
  boolean_filter :auth_enabled
  filter :auth_user
  filter :auth_password
  filter :incoming_auth_username
  filter :incoming_auth_password
  filter :incoming_auth_allow_jwt
  filter :codec_group, input_html: { class: 'chosen' }, collection: proc { CodecGroup.pluck(:name, :id) }
  filter :diversion_send_mode
  filter :sip_schema_id, as: :select, collection: proc { Gateway::SIP_SCHEMAS.invert }
  filter :privacy_mode_id, as: :select, collection: proc { Gateway::PRIVACY_MODES.invert }
  filter :dump_level_id, as: :select, collection: proc { Gateway::DUMP_LEVELS.invert }

  association_ajax_filter :termination_src_numberlist_id_eq,
                          label: 'Termination SRC Numberlist',
                          scope: -> { Routing::Numberlist.order(:name) },
                          path: '/numberlists/search'

  association_ajax_filter :termination_dst_numberlist_id_eq,
                          label: 'Termination DST Numberlist',
                          scope: -> { Routing::Numberlist.order(:name) },
                          path: '/numberlists/search'

  filter :stir_shaken_crt, as: :select, input_html: { class: 'chosen' }
  filter :throttling_profile, as: :select, input_html: { class: 'chosen' }
  filter :scheduler, as: :select, input_html: { class: 'chosen' }

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    tabs do
      tab :general do
        f.inputs 'General' do
          f.input :name
          f.input :enabled
          f.contractor_input :contractor_id
          f.input :is_shared
          f.association_ajax_input :gateway_group_id,
                                   label: 'Gateway Group',
                                   scope: GatewayGroup.order(:name),
                                   path: '/gateway_groups/search',
                                   fill_params: { vendor_id_eq: f.object.contractor_id },
                                   input_html: {
                                     'data-path-params': { 'q[vendor_id_eq]': '.contractor_id-input' }.to_json,
                                     'data-required-param': 'q[vendor_id_eq]'
                                   }
          f.input :priority
          f.input :weight
          f.input :pop, as: :select, include_blank: 'Any', input_html: { class: 'chosen' }

          f.input :scheduler, as: :select, input_html: { class: 'chosen' }

          f.input :allow_origination
          f.input :allow_termination

          f.input :origination_capacity
          f.input :termination_capacity
          f.input :termination_subscriber_capacity
          f.input :termination_cps_limit
          f.input :termination_cps_wsize
          f.input :termination_subscriber_cps_limit
          f.input :termination_subscriber_cps_wsize
          f.input :acd_limit
          f.input :asr_limit
          f.input :short_calls_limit
        end
      end
      tab :sst do
        f.inputs 'Session timers' do
          f.input :sst_enabled
          f.input :sst_session_expires
          f.input :sst_minimum_timer
          f.input :sst_maximum_timer
          f.input :session_refresh_method, as: :select, include_blank: false
          f.input :sst_accept501
        end
      end

      tab :sensor do
        f.inputs 'Sensor' do
          f.input :sensor_level
          f.input :sensor
        end
      end
      tab :signaling do
        columns do
          column do
            f.inputs 'General' do
              f.input :relay_options
              f.input :relay_reinvite
              f.input :relay_hold
              f.input :relay_prack
              f.input :rel100_mode, as: :select, include_blank: false
              f.input :relay_update
              f.input :transit_headers_from_origination
              f.input :transit_headers_from_termination
              f.input :sip_interface_name

              if f.object.external_id.nil? || authorized?(:allow_incoming_auth_credentials)
                f.input :incoming_auth_username, hint: "#{link_to('Сlick to fill random username', 'javascript:void(0)', onclick: 'generateCredential(this)')}. #{t('formtastic.hints.gateway.incoming_auth_username')}".html_safe
                f.input :incoming_auth_password, as: :string, input_html: { autocomplete: 'off' }, hint: link_to('Сlick to fill random password', 'javascript:void(0)', onclick: 'generateCredential(this)')
              end

              f.input :incoming_auth_allow_jwt
            end

            f.inputs 'Origination' do
              f.input :orig_next_hop
              f.input :orig_append_headers_req, as: :newline_array_of_headers
              f.input :orig_append_headers_reply, as: :newline_array_of_headers
              f.input :orig_use_outbound_proxy
              f.input :orig_force_outbound_proxy
              f.input :orig_proxy_transport_protocol, as: :select, include_blank: false
              f.input :orig_outbound_proxy
              f.input :transparent_dialog_id
              f.input :dialog_nat_handling
              f.input :orig_disconnect_policy, input_html: { class: 'chosen' }, include_blank: true
            end
          end
          column do
            f.inputs 'Termination' do
              f.input :dump_level_id, as: :select, include_blank: false, collection: Gateway::DUMP_LEVELS.invert
              f.input :transport_protocol, as: :select, include_blank: false
              f.input :sip_schema_id, as: :select, include_blank: false, collection: Gateway::SIP_SCHEMAS.invert
              f.input :host
              f.input :port
              f.input :registered_aor_mode_id, as: :select, include_blank: false,
                                               collection: Gateway::REGISTERED_AOR_MODES.invert
              f.input :network_protocol_priority, as: :select, include_blank: false
              f.input :resolve_ruri
              f.input :preserve_anonymous_from_domain

              f.input :auth_enabled
              f.input :auth_user
              f.input :auth_password, as: :string, input_html: { autocomplete: 'off' }
              f.input :auth_from_user
              f.input :auth_from_domain

              f.input :term_use_outbound_proxy
              f.input :term_force_outbound_proxy
              f.input :term_proxy_transport_protocol, as: :select, include_blank: false
              f.input :term_outbound_proxy
              f.input :term_next_hop_for_replies
              f.input :term_next_hop
              f.input :term_disconnect_policy, input_html: { class: 'chosen' }, include_blank: true
              f.input :term_append_headers_req, as: :newline_array_of_headers
              f.input :sdp_alines_filter_type, as: :select, include_blank: false
              f.input :sdp_alines_filter_list
              f.input :ringing_timeout
              f.input :allow_1xx_without_to_tag
              f.input :force_cancel_routeset
              f.input :max_30x_redirects
              f.input :max_transfers
              f.input :transfer_append_headers_req, as: :newline_array_of_headers
              f.input :transfer_tel_uri_host
              f.input :sip_timer_b
              f.input :dns_srv_failover_timer
              f.input :suppress_early_media
              f.input :fake_180_timer
              f.input :send_lnp_information
              f.input :throttling_profile, input_html: { class: 'chosen' }, include_blank: true
            end
          end
        end
      end
      tab 'Translations' do
        f.inputs 'Translations' do
          f.input :privacy_mode_id, as: :select, include_blank: false, collection: Gateway::PRIVACY_MODES.invert
          f.association_ajax_input :termination_src_numberlist_id,
                                  label: 'Termination SRC Numberlist',
                                  scope: Routing::Numberlist.order(:name),
                                  path: '/numberlists/search'

          f.association_ajax_input :termination_dst_numberlist_id,
                                  label: 'Termination DST Numberlist',
                                  scope: Routing::Numberlist.order(:name),
                                  path: '/numberlists/search'
          f.input :diversion_send_mode, include_blank: false
          f.input :diversion_domain
          f.input :diversion_rewrite_rule
          f.input :diversion_rewrite_result

          f.input :pai_send_mode_id, as: :select, include_blank: false,
                                     collection: Gateway::PAI_SEND_MODES.invert
          f.input :pai_domain

          f.input :src_name_rewrite_rule
          f.input :src_name_rewrite_result
          f.input :src_rewrite_rule
          f.input :src_rewrite_result
          f.input :dst_rewrite_rule
          f.input :dst_rewrite_result
          f.input :to_rewrite_rule
          f.input :to_rewrite_result
          f.input :lua_script, input_html: { class: 'chosen' }, include_blank: 'None'
        end
      end
      tab :media do
        f.inputs 'Media settings' do
          f.input :sdp_c_location, as: :select, include_blank: false
          f.input :codec_group, input_html: { class: 'chosen' }
          f.input :try_avoid_transcoding
          f.input :proxy_media
          f.input :single_codec_in_200ok
          f.input :force_symmetric_rtp
          f.input :symmetric_rtp_nonstop
          f.input :rtp_ping
          f.input :rtp_timeout
          f.input :filter_noaudio_streams
          f.input :rtp_relay_timestamp_aligning
          f.input :rtp_force_relay_cn
          f.input :force_one_way_early_media
          f.input :rtp_interface_name
          f.input :media_encryption_mode, as: :select, include_blank: false
          f.input :ice_mode_id, as: :select, include_blank: false, collection: Gateway::ICE_MODES.invert
          f.input :rtcp_mux_mode_id, as: :select, include_blank: false, collection: Gateway::RTCP_MUX_MODES.invert
          f.input :rtcp_feedback_mode_id, as: :select, include_blank: false, collection: Gateway::RTCP_FEEDBACK_MODES.invert
          f.input :rtp_acl, as: :array_of_strings
        end
      end
      tab :dtmf do
        f.inputs 'DTMF' do
          f.input :force_dtmf_relay
          f.input :dtmf_send_mode, as: :select, include_blank: false
          f.input :dtmf_receive_mode, as: :select, include_blank: false
          f.input :rx_inband_dtmf_filtering_mode, as: :select, include_blank: false
          f.input :tx_inband_dtmf_filtering_mode, as: :select, include_blank: false
        end
      end
      tab :radius do
        f.inputs 'RADIUS' do
          f.input :radius_accounting_profile, input_html: { class: 'chosen' }, include_blank: 'None'
        end
      end
      tab :stir_shaken do
        f.inputs 'STIR/SHAKEN' do
          f.input :stir_shaken_mode_id, as: :select, include_blank: false,
                                        collection: Gateway::STIR_SHAKEN_MODES.invert
          f.input :stir_shaken_crt, as: :select, input_html: { class: 'chosen' }
        end
      end
    end

    f.actions
  end

  show do |s|
    tabs do
      tab :general do
        attributes_table_for s do
          row :id
          row :uuid
          row :name
          row :external_id
          row :enabled
          row :locked
          row :contractor do
            auto_link(s.contractor, s.contractor.decorated_display_name)
          end
          row :is_shared
          row :gateway_group
          row :priority
          row :weight
          row :pop
          row :scheduler do |row|
            row.scheduler.try(:decorated_display_name)
          end
          row :allow_origination
          row :allow_termination
          row :origination_capacity
          row :termination_capacity
          row :termination_subscriber_capacity
          row :termination_cps_limit
          row :termination_cps_wsize
          row :termination_subscriber_cps_limit
          row :termination_subscriber_cps_wsize
          row :acd_limit
          row :asr_limit
          row :short_calls_limit
        end
      end
      tab :sst do
        attributes_table_for s do
          row :sst_enabled
          row :sst_session_expires
          row :sst_minimum_timer
          row :sst_maximum_timer
          row :session_refresh_method
          row :sst_accept501
        end
      end

      tab :sensor do
        attributes_table_for s do
          row :sensor_level
          row :sensor
        end
      end

      tab :signaling do
        panel 'General' do
          attributes_table_for s do
            row :relay_options
            row :relay_reinvite
            row :relay_hold
            row :relay_prack
            row :rel100_mode
            row :relay_update
            row :transit_headers_from_origination
            row :transit_headers_from_termination
            row :sip_interface_name
          end
        end
        panel 'Origination' do
          attributes_table_for s do
            row :orig_next_hop
            row :orig_append_headers_req do |row|
              pre row.orig_append_headers_req.join("\r\n")
            end
            row :orig_append_headers_reply do |row|
              pre row.orig_append_headers_reply.join("\r\n")
            end
            row :orig_use_outbound_proxy
            row :orig_force_outbound_proxy
            row :orig_proxy_transport_protocol
            row :orig_outbound_proxy
            row :transparent_dialog_id
            row :dialog_nat_handling
            row :orig_disconnect_policy

            if s.external_id.nil? || authorized?(:allow_incoming_auth_credentials)
              row :incoming_auth_username
              row :incoming_auth_password
            end
            row :incoming_auth_allow_jwt
          end
        end
        panel 'Termination' do
          attributes_table_for s do
            row :dump_level_id, &:dump_level_name
            row :transport_protocol
            row :sip_schema_id, &:sip_schema_name
            row :host
            row :port

            row :registered_aor_mode, &:registered_aor_mode_name

            row :network_protocol_priority
            row :resolve_ruri
            row :preserve_anonymous_from_domain

            row :auth_enabled
            row :auth_user
            row :auth_password
            row :auth_from_user
            row :auth_from_domain

            row :term_use_outbound_proxy
            row :term_force_outbound_proxy
            row :term_proxy_transport_protocol
            row :term_outbound_proxy
            row :term_next_hop_for_replies
            row :term_next_hop
            row :term_disconnect_policy
            row :term_append_headers_req do |row|
              pre row.term_append_headers_req.join("\r\n")
            end
            row :sdp_alines_filter_type
            row :sdp_alines_filter_list
            row :ringing_timeout
            row :allow_1xx_without_to_tag
            row :force_cancel_routeset
            row :max_30x_redirects
            row :max_transfers
            row :transfer_append_headers_req do |row|
              pre row.transfer_append_headers_req.join("\r\n")
            end
            row :transfer_tel_uri_host
            row :sip_timer_b
            row :dns_srv_failover_timer
            row :suppress_early_media
            row :fake_180_timer
            row :send_lnp_information
            row :throttling_profile
          end
        end
      end
      tab 'Translations' do
        attributes_table_for s do
          row :privacy_mode_id, &:privacy_mode_name
          row :termination_src_numberlist
          row :termination_dst_numberlist
          row :diversion_send_mode
          row :diversion_domain
          row :diversion_rewrite_rule
          row :diversion_rewrite_result

          row :pai_send_mode, &:pai_send_mode_name
          row :pai_domain

          row :src_name_rewrite_rule
          row :src_name_rewrite_result
          row :src_rewrite_rule
          row :src_rewrite_result
          row :dst_rewrite_rule
          row :dst_rewrite_result
          row :to_rewrite_rule
          row :to_rewrite_result
          row :lua_script
        end
      end

      tab :media do
        attributes_table_for s do
          row :sdp_c_location
          row :codec_group, input_html: { class: 'chosen' }
          row :try_avoid_transcoding
          row :proxy_media
          row :single_codec_in_200ok
          row :force_symmetric_rtp
          row :symmetric_rtp_nonstop
          row :rtp_ping
          row :rtp_timeout
          row :filter_noaudio_streams
          row :rtp_relay_timestamp_aligning
          row :rtp_force_relay_cn
          row :force_one_way_early_media
          row :rtp_interface_name
          row :media_encryption_mode
          row :ice_mode_name
          row :rtcp_mux_mode_name
          row :rtcp_feedback_mode_name
          row :rtp_acl
        end
      end
      tab :dtmf do
        attributes_table_for s do
          row :force_dtmf_relay
          row :dtmf_send_mode
          row :dtmf_receive_mode
          row :tx_inband_dtmf_filtering_mode
          row :rx_inband_dtmf_filtering_mode
        end
      end
      tab :radius do
        attributes_table_for s do
          row :radius_accounting_profile
        end
      end

      tab :stir_shaken do
        attributes_table_for s do
          row :stir_shaken_mode, &:stir_shaken_mode_name
          row :stir_shaken_crt
        end
      end

      if s.allow_origination?
        tab :origination_chart do
          panel '24h' do
            render partial: 'charts/orig_gateway'
          end
          panel 'History' do
            render partial: 'charts/orig_gateway_agg'
          end
        end
      end

      if s.allow_termination?
        tab :termination_chart do
          panel '24h' do
            render partial: 'charts/term_gateway'
          end
          panel 'History' do
            render partial: 'charts/term_gateway_agg'
          end
          panel 'PDD Distribution' do
            render partial: 'charts/gateway_pdd_distribution'
          end
        end
      end

      tab :incoming_registrations do
        if assigns[:registrations].data.any?
          table_for assigns[:registrations].data, class: 'index_table' do
            column :contact
            column :expires
            column :path
            column :user_agent
          end
        end
      end

      tab :comments do
        active_admin_comments
      end
    end
  end

  sidebar :links, only: %i[show edit] do
    ul do
      li do
        link_to 'Dialpeers', dialpeers_path(q: { gateway_id_eq: params[:id] })
      end
    end
  end
end
