ActiveAdmin.register Gateway do

  menu parent: "Equipment", priority: 75

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status
  acts_as_stat
  acts_as_quality_stat
  acts_as_lock
  acts_as_stats_actions

  decorate_with GatewayDecorator


  acts_as_export :id, :name, :enabled,
                 [:gateway_group_name, proc { |row| row.gateway_group.try(:name) }],
                 :priority,
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 [:contractor_name, proc { |row| row.contractor.try(:name) }],
                 :allow_origination, :allow_termination, :sst_enabled,
                 :origination_capacity, :termination_capacity,
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
                 [:orig_disconnect_policy_name, proc { |row| row.orig_disconnect_policy.try(:name) }],
                 [:transport_protocol_name, proc { |row| row.transport_protocol.try(:name) }],
                 :host, :port, :resolve_ruri,
                 [:diversion_policy_name, proc { |row| row.diversion_policy.try(:name) }],
                 :diversion_rewrite_rule, :diversion_rewrite_result,
                 :src_name_rewrite_rule, :src_name_rewrite_result,
                 :src_rewrite_rule, :src_rewrite_result,
                 :dst_rewrite_rule, :dst_rewrite_result,
                 :auth_enabled, :auth_user, :auth_password, :auth_from_user, :auth_from_domain,
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
                 :anonymize_sdp, :proxy_media, :single_codec_in_200ok, :transparent_seqno, :transparent_ssrc, :force_symmetric_rtp, :symmetric_rtp_nonstop, :symmetric_rtp_ignore_rtcp, :force_dtmf_relay, :rtp_ping,
                 :rtp_timeout,
                 :filter_noaudio_streams,
                 :rtp_relay_timestamp_aligning,
                 :rtp_force_relay_cn,
                 [:dtmf_send_mode_name, proc { |row| row.dtmf_send_mode.try(:name) }],
                 [:dtmf_receive_mode_name, proc { |row| row.dtmf_receive_mode.try(:name) }],
                 :suppress_early_media,
                 :send_lnp_information,
                 :force_one_way_early_media

  acts_as_import resource_class: Importing::Gateway
  acts_as_batch_changeable [:enabled, :priority, :origination_capacity, :termination_capacity]

  scope :locked
  scope :with_radius_accounting

  includes :contractor, :gateway_group, :pop, :statistic, :diversion_policy,
           :session_refresh_method, :codec_group,
           :term_disconnect_policy, :orig_disconnect_policy,
           :sdp_c_location, :sdp_alines_filter_type,
           :sensor, :sensor_level,
           :dtmf_send_mode, :dtmf_receive_mode,
           :radius_accounting_profile,
           :transport_protocol, :term_proxy_transport_protocol, :orig_proxy_transport_protocol,
           :rel100_mode

  controller do
    def resource_params
      return [] if request.get?
      [params[active_admin_config.resource_class.name.underscore.to_sym].permit!]
    end
  end


  collection_action :with_contractor do
    @gateways = Contractor.find(params[:contractor_id]).gateways
    render text: view_context.options_from_collection_for_select(@gateways, :id, :display_name)
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

    column :gateway_group
    column :priority
    column :pop

    column :transport_protocol
    column :host, sortable: 'host' do |gw|
      "#{gw.host}:#{gw.port}".chomp(":")
    end

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

    #SST
    column :sst_enabled
    column :sst_session_expires
    column :sst_minimum_timer
    column :sst_maximum_timer
    column :session_refresh_method
    column :sst_accept501

    #SENSOR
    column :sensor
    column :sensor_level

    #SIGNALING
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
    column :auth_enabled
    column :auth_user
    column :auth_password
    column :auth_from_user
    column :auth_from_domain

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
    column :sip_timer_b
    column :dns_srv_failover_timer
    column :suppress_early_media
    column :fake_180_timer
    column :send_lnp_information

    #TRANSLATIONS
    column :diversion_policy
    column :diversion_rewrite_rule
    column :diversion_rewrite_result
    column :src_name_rewrite_rule
    column :src_name_rewrite_result
    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result
    #MEDIA
    column :sdp_c_location
    column :codec_group
    column :anonymize_sdp
    column :proxy_media
    column :single_codec_in_200ok
    column :transparent_seqno
    column :transparent_ssrc
    column :force_symmetric_rtp
    column :symmetric_rtp_nonstop
    column :symmetric_rtp_ignore_rtcp
    column :rtp_ping
    column :rtp_timeout
    column :filter_noaudio_streams
    column :rtp_relay_timestamp_aligning
    column :rtp_force_relay_cn
    column :force_one_way_early_media
    column :rtp_interface_name
    ## DTMF
    column :force_dtmf_relay
    column :dtmf_send_mode
    column :dtmf_receive_mode
    ##RADIUS
    column :radius_accounting_profile
    column :external_id
  end

  filter :id
  filter :name
  filter :gateway_group, input_html: {class: 'chosen'}
  filter :pop, input_html: {class: 'chosen'}
  filter :contractor, input_html: {class: 'chosen'}
  filter :transport_protocol
  filter :host
  filter :enabled, as: :select, collection: [["Yes", true], ["No", false]]
  filter :allow_origination, as: :select, collection: [["Yes", true], ["No", false]]
  filter :allow_termination, as: :select, collection: [["Yes", true], ["No", false]]
  filter :proxy_media, as: :select, collection: [["Yes", true], ["No", false]]

  filter :statistic_calls, as: :numeric
  filter :statistic_total_duration, as: :numeric
  filter :statistic_asr, as: :numeric
  filter :statistic_acd, as: :numeric
  filter :external_id
  filter :radius_accounting_profile, input_html: {class: 'chosen'}

  form do |f|
    f.semantic_errors *f.object.errors.keys

    tabs do
      tab :general do
        f.inputs "General" do
          f.input :name, hint: I18n.t('hints.equipment.gateways.name')
          f.input :external_id, hint: I18n.t('hints.equipment.gateways.external_id')
          f.input :enabled
          f.input :contractor, hint: I18n.t('hints.equipment.gateways.contractor'),
                  input_html: {
                      class: 'chosen',
                      onchange: remote_chosen_request(:get, with_contractor_gateway_groups_path, {contractor_id: "$(this).val()"}, :gateway_gateway_group_id)
                  }
          f.input :gateway_group, hint: I18n.t('hints.equipment.gateways.gateway_group'), as: :select, include_blank: 'None',
                  input_html: {class: 'chosen'}
          f.input :priority, hint: I18n.t('hints.equipment.gateways.priority')
          f.input :pop, input_html: {class: 'chosen'}, hint: I18n.t('hints.equipment.gateways.pop')

          f.input :allow_origination
          f.input :allow_termination

          f.input :origination_capacity, hint: I18n.t('hints.equipment.gateways.origination_capacity')
          f.input :termination_capacity, hint: I18n.t('hints.equipment.gateways.termination_capacity')
          f.input :acd_limit, hint: I18n.t('hints.equipment.gateways.acd_limit')
          f.input :asr_limit, hint: I18n.t('hints.equipment.gateways.asr_limit')
          f.input :short_calls_limit, hint: I18n.t('hints.equipment.gateways.short_calls_limit')
        end
      end
      tab :sst do
        f.inputs "Session timers" do
          f.input :sst_enabled
          f.input :sst_session_expires, hint: I18n.t('hints.equipment.gateways.sst_session_expires')
          f.input :sst_minimum_timer, hint: I18n.t('hints.equipment.gateways.sst_minimum_timer')
          f.input :sst_maximum_timer, hint: I18n.t('hints.equipment.gateways.sst_maximum_timer')
          f.input :session_refresh_method, hint: I18n.t('hints.equipment.gateways.session_refresh_method')
          f.input :sst_accept501
        end
      end

      tab :sensor do
        f.inputs "Sensor" do
          f.input :sensor_level, hint: I18n.t('hints.equipment.gateways.sensor_level')
          f.input :sensor, hint: I18n.t('hints.equipment.gateways.sensor')
        end
      end
      tab :signaling do
        f.inputs "General" do
          f.input :relay_options
          f.input :relay_reinvite
          f.input :relay_hold
          f.input :relay_prack
          f.input :rel100_mode, hint: I18n.t('hints.equipment.gateways.rel100_mode'), as: :select, include_blank: false
          f.input :relay_update
          f.input :transit_headers_from_origination, hint: I18n.t('hints.equipment.gateways.transit_headers')
          f.input :transit_headers_from_termination, hint: I18n.t('hints.equipment.gateways.transit_headers')
          f.input :sip_interface_name, hint: I18n.t('hints.equipment.gateways.sip_interface_name')
        end
        f.inputs "Origination" do
          f.input :orig_next_hop, hint: I18n.t('hints.equipment.gateways.orig_next_hop')
          f.input :orig_append_headers_req, hint: I18n.t('hints.equipment.gateways.orig_append_headers_req')
          f.input :orig_use_outbound_proxy
          f.input :orig_force_outbound_proxy
          f.input :orig_proxy_transport_protocol, as: :select, include_blank: false, hint: I18n.t('hints.equipment.gateways.orig_proxy_transport_protocol')
          f.input :orig_outbound_proxy, hint: I18n.t('hints.equipment.gateways.orig_outbound_proxy')
          f.input :transparent_dialog_id
          f.input :dialog_nat_handling
          f.input :orig_disconnect_policy, hint: I18n.t('hints.equipment.gateways.orig_disconnect_policy')
        end
        f.inputs "Termination" do
          f.input :transport_protocol, as: :select, include_blank: false, hint: I18n.t('hints.equipment.gateways.transport_protocol')
          f.input :host, hint: I18n.t('hints.equipment.gateways.host')
          f.input :port, hint: I18n.t('hints.equipment.gateways.port')
          f.input :resolve_ruri
          f.input :auth_enabled
          f.input :auth_user, hint: I18n.t('hints.equipment.gateways.auth_user')
          f.input :auth_password, as: :string, input_html: {autocomplete: 'off'}, hint: I18n.t('hints.equipment.gateways.auth_password')
          f.input :auth_from_user, hint: I18n.t('hints.equipment.gateways.auth_from_user')
          f.input :auth_from_domain, hint: I18n.t('hints.equipment.gateways.auth_from_domain')
          f.input :term_use_outbound_proxy
          f.input :term_force_outbound_proxy
          f.input :term_proxy_transport_protocol, as: :select, include_blank: false, hint: I18n.t('hints.equipment.gateways.term_proxy_transport_protocol')
          f.input :term_outbound_proxy, hint: I18n.t('hints.equipment.gateways.term_outbound_proxy')
          f.input :term_next_hop_for_replies
          f.input :term_next_hop, hint: I18n.t('hints.equipment.gateways.term_next_hop')
          f.input :term_disconnect_policy, hint: I18n.t('hints.equipment.gateways.term_disconnect_policy')
          f.input :term_append_headers_req, hint: I18n.t('hints.equipment.gateways.term_append_headers_req')
          f.input :sdp_alines_filter_type, hint: I18n.t('hints.equipment.gateways.sdp_alines_filter_type')
          f.input :sdp_alines_filter_list, hint: I18n.t('hints.equipment.gateways.sdp_alines_filter_list')
          f.input :ringing_timeout, hint: I18n.t('hints.equipment.gateways.ringing_timeout')
          f.input :allow_1xx_without_to_tag
          f.input :sip_timer_b, hint: I18n.t('hints.equipment.gateways.sip_timer_b')
          f.input :dns_srv_failover_timer, hint: I18n.t('hints.equipment.gateways.dns_srv_failover_timer')
          f.input :suppress_early_media
          f.input :fake_180_timer, hint: I18n.t('hints.equipment.gateways.fake_180_timer')
          f.input :send_lnp_information
        end
      end
      tab "Translations" do
        f.inputs "Translations" do
          f.input :diversion_policy, hint: I18n.t('hints.equipment.gateways.diversion_policy')
          f.input :diversion_rewrite_rule, hint: I18n.t('hints.equipment.gateways.diversion_rewrite_rule')
          f.input :diversion_rewrite_result, hint: I18n.t('hints.equipment.gateways.diversion_rewrite_result')
          f.input :src_name_rewrite_rule, hint: I18n.t('hints.equipment.gateways.src_name_rewrite_rule')
          f.input :src_name_rewrite_result, hint: I18n.t('hints.equipment.gateways.src_name_rewrite_result')
          f.input :src_rewrite_rule, hint: I18n.t('hints.equipment.gateways.src_rewrite_rule')
          f.input :src_rewrite_result, hint: I18n.t('hints.equipment.gateways.src_rewrite_result')
          f.input :dst_rewrite_rule, hint: I18n.t('hints.equipment.gateways.dst_rewrite_rule')
          f.input :dst_rewrite_result, hint: I18n.t('hints.equipment.gateways.dst_rewrite_result')
        end
      end
      tab :media do
        f.inputs "Media settings" do
          f.input :sdp_c_location, hint: I18n.t('hints.equipment.gateways.sdp_c_location')
          f.input :codec_group, hint: I18n.t('hints.equipment.gateways.codec_group')
          f.input :anonymize_sdp
          f.input :proxy_media
          f.input :single_codec_in_200ok
          f.input :transparent_seqno
          f.input :transparent_ssrc
          f.input :force_symmetric_rtp
          f.input :symmetric_rtp_nonstop
          f.input :symmetric_rtp_ignore_rtcp
          f.input :rtp_ping
          f.input :rtp_timeout, hint: I18n.t('hints.equipment.gateways.rtp_timeout')
          f.input :filter_noaudio_streams
          f.input :rtp_relay_timestamp_aligning
          f.input :rtp_force_relay_cn
          f.input :force_one_way_early_media
          f.input :rtp_interface_name, hint: I18n.t('hints.equipment.gateways.rtp_interface_name')
        end
      end
      tab :dtmf do
        f.inputs :dtmf do
          f.input :force_dtmf_relay
          f.input :dtmf_send_mode, hint: I18n.t('hints.equipment.gateways.dtmf_send_mode')
          f.input :dtmf_receive_mode, hint: I18n.t('hints.equipment.gateways.dtmf_receive_mode')
        end

      end
      tab :radius do
        f.inputs :radius do
          f.input :radius_accounting_profile, hint: I18n.t('hints.equipment.gateways.radius_accounting_profile')
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
          row :name
          row :external_id
          row :enabled
          row :locked
          row :contractor do
            auto_link(s.contractor, s.contractor.decorated_display_name)
          end
          row :gateway_group
          row :priority
          row :pop
          row :allow_origination
          row :allow_termination
          row :origination_capacity
          row :termination_capacity
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
        panel "General" do
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
        panel "Origination" do
          attributes_table_for s do
            row :orig_next_hop
            row :orig_append_headers_req
            row :orig_use_outbound_proxy
            row :orig_force_outbound_proxy
            row :orig_proxy_transport_protocol
            row :orig_outbound_proxy
            row :transparent_dialog_id
            row :dialog_nat_handling
            row :orig_disconnect_policy
          end
        end
        panel "Termination" do
          attributes_table_for s do
            row :transport_protocol
            row :host
            row :port
            row :resolve_ruri
            row :auth_enabled
            row :auth_user
            row :auth_password
            row :auth_from_user
            row :auth_from_domain
            row :term_use_outbound_proxy
            row :term_force_outbound_proxy
            row :orig_proxy_transport_protocol
            row :term_outbound_proxy
            row :term_next_hop_for_replies
            row :term_next_hop
            row :term_disconnect_policy
            row :term_append_headers_req
            row :sdp_alines_filter_type
            row :sdp_alines_filter_list
            row :ringing_timeout
            row :allow_1xx_without_to_tag
            row :sip_timer_b
            row :dns_srv_failover_timer
            row :suppress_early_media
            row :fake_180_timer
            row :send_lnp_information
          end
        end
      end
      tab "Translations" do
        attributes_table_for s do
          row :diversion_policy
          row :diversion_rewrite_rule
          row :diversion_rewrite_result
          row :src_name_rewrite_rule
          row :src_name_rewrite_result
          row :src_rewrite_rule
          row :src_rewrite_result
          row :dst_rewrite_rule
          row :dst_rewrite_result
        end
      end


      tab :media do
        attributes_table_for s do
          row :sdp_c_location
          row :codec_group, input_html: {class: 'chosen'}
          row :anonymize_sdp
          row :proxy_media
          row :single_codec_in_200ok
          row :transparent_seqno
          row :transparent_ssrc
          row :force_symmetric_rtp
          row :symmetric_rtp_nonstop
          row :symmetric_rtp_ignore_rtcp
          row :rtp_ping
          row :rtp_timeout
          row :filter_noaudio_streams
          row :rtp_relay_timestamp_aligning
          row :rtp_force_relay_cn
          row :force_one_way_early_media
          row :rtp_interface_name
        end
      end
      tab :dtmf do
        attributes_table_for s do
          row :force_dtmf_relay
          row :dtmf_send_mode
          row :dtmf_receive_mode
        end
      end
      tab :radius do
        attributes_table_for s do
          row :radius_accounting_profile
        end
      end


      tab :origination_chart do
        panel '24h' do
          render partial: 'charts/orig_gateway'
        end
        panel 'History' do
          render partial: 'charts/orig_gateway_agg'
        end
      end if s.allow_origination?

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

      end if s.allow_termination?

    end
  end

  sidebar :links, only: [:show, :edit] do
    ul do
      li do
        link_to "Dialpeers", dialpeers_path(q: {gateway_id_eq: params[:id]})
      end
    end
  end


end
