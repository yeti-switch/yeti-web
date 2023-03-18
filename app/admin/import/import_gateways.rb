# frozen_string_literal: true

ActiveAdmin.register Importing::Gateway do
  filter :name
  filter :contractor,
         input_html: { class: 'chosen-ajax', 'data-path': '/contractors/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:contractor_id_eq]
           resource_id ? Contractor.where(id: resource_id) : []
         }

  filter :gateway_group, input_html: { class: 'chosen' }
  boolean_filter :is_changed

  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :is_changed

    column :name
    column :enabled
    column :gateway_group, sortable: :gateway_group_name
    column :contractor, sortable: :contractor_name

    column :is_shared

    column :priority
    column :weight

    column :pop, sortable: :pop_name
    column :transport_protocol_name
    column :host
    column :port
    column :registered_aor_mode, &:registered_aor_mode_display_name

    column :origination_capacity
    column :termination_capacity

    column :termination_src_numberlist, sortable: :termination_src_numberlist_name
    column :termination_dst_numberlist, sortable: :termination_dst_numberlist_name

    column :diversion_send_mode, sortable: :diversion_send_mode_name
    column :diversion_domain
    column :diversion_rewrite_rule
    column :diversion_rewrite_result

    column :src_name_rewrite_rule
    column :src_name_rewrite_result

    column :src_rewrite_rule
    column :src_rewrite_result

    column :dst_rewrite_rule
    column :dst_rewrite_result
    column :lua_script

    column :acd_limit
    column :asr_limit
    column :short_calls_limit

    column :allow_termination
    column :allow_origination

    column :proxy_media

    column :incoming_auth_username
    column :incoming_auth_password

    column :auth_enabled
    column :auth_user
    column :auth_password
    column :auth_from_user
    column :auth_from_domain

    column :term_use_outbound_proxy
    column :term_proxy_transport_protocol
    column :term_outbound_proxy
    column :term_force_outbound_proxy
    column :term_next_hop
    column :orig_next_hop
    column :term_append_headers_req
    column :orig_append_headers_req
    column :sdp_alines_filter_type, sortable: :sdp_alines_filter_type_name
    column :sdp_alines_filter_list
    column :orig_disconnect_policy, sortable: :orig_disconnect_policy_name
    column :term_disconnect_policy, sortable: :term_disconnect_policy_name

    column :codec_group, sortable: :codec_group_name
    column :single_codec_in_200ok
    column :term_next_hop_for_replies

    # SST
    column :sst_enabled
    column :sst_session_expires
    column :sst_minimum_timer
    column :sst_maximum_timer
    column :session_refresh_method, sortable: :session_refresh_method_name
    column :sst_accept501

    # SENSOR
    column :sensor, sortable: :sensor_name
    column :sensor_level, sortable: :sensor_level_name

    # SIGNALING
    column :preserve_anonymous_from_domain
    column :relay_options
    column :relay_reinvite
    column :relay_prack
    column :rel100_mode, sortable: :rel100_mode_name
    column :force_cancel_routeset

    # DTMF
    column :rx_inband_dtmf_filtering_mode, sortable: :rx_inband_dtmf_filtering_mode_name
    column :tx_inband_dtmf_filtering_mode, sortable: :tx_inband_dtmf_filtering_mode_name

    column :relay_update
    column :transit_headers_from_origination
    column :transit_headers_from_termination
    column :sip_interface_name
  end
end
