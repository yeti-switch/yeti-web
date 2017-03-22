ActiveAdmin.register Importing::Gateway do

  filter :name
  filter :contractor, input_html: {class: 'chosen'}
  filter :gateway_group, input_html: {class: 'chosen'}

  acts_as_import_preview

  controller do
    def resource_params
      return [] if request.get?
      [ params[active_admin_config.resource_class.model_name.param_key.to_sym].permit! ]
    end
    def scoped_collection
      super.includes(:contractor, :gateway_group)
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :name
    column :enabled

    column :gateway_group, sortable: :gateway_group_name do |row|
      if row.gateway_group.blank?
        row.gateway_group_name
      else
        auto_link(row.gateway_group, row.gateway_group_name)
      end
    end

    column :contractor, sortable: :contractor_name do |row|
      if row.contractor.blank?
        row.contractor_name
      else
        auto_link(row.contractor, row.contractor_name)
      end
    end

    column :priority

    column :pop, sortable: :pop_name do |row|
      if row.pop.blank?
        row.pop_name
      else
        auto_link(row.pop, row.pop_name)
      end
    end

    column :transport_protocol_name
    column :host, sortable: 'host' do |gw|
      "#{gw.host}:#{gw.port}".chomp(":")
    end

    column :capacity

    column :diversion_policy, sortable: :diversion_policy_name do |row|
      if row.diversion_policy.blank?
        row.diversion_policy_name
      else
        auto_link(row.diversion_policy, row.diversion_policy_name)
      end
    end

    column :diversion_rewrite_rule
    column :diversion_rewrite_result

    column :src_name_rewrite_rule
    column :src_name_rewrite_result

    column :src_rewrite_rule
    column :src_rewrite_result

    column :dst_rewrite_rule
    column :dst_rewrite_result

    column :acd_limit
    column :asr_limit

    column :allow_termination
    column :allow_origination

    column :anonymize_sdp
    column :proxy_media

    column :transparent_seqno
    column :transparent_ssrc

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

    column :sdp_alines_filter_type, sortable: :sdp_alines_filter_type_name do |row|
      if row.sdp_alines_filter_type.blank?
        row.sdp_alines_filter_type_name
      else
        auto_link(row.sdp_alines_filter_type, row.sdp_alines_filter_type_name)
      end
    end

    column :sdp_alines_filter_list

    column :orig_disconnect_policy, sortable: :orig_disconnect_policy_name do |row|
      if row.orig_disconnect_policy.blank?
        row.orig_disconnect_policy_name
      else
        auto_link(row.orig_disconnect_policy, row.orig_disconnect_policy_name)
      end
    end

    column :term_disconnect_policy, sortable: :term_disconnect_policy_name do |row|
      if row.term_disconnect_policy.blank?
        row.term_disconnect_policy_name
      else
        auto_link(row.term_disconnect_policy, row.term_disconnect_policy_name)
      end
    end

    column :codec_group, sortable: :codec_group_name do |row|
      if row.codec_group.blank?
        row.codec_group_name
      else
        auto_link(row.codec_group, row.codec_group_name)
      end
    end

    column :single_codec_in_200ok

    column :term_next_hop_for_replies

    column :session_refresh_method, sortable: :session_refresh_method_name do |row|
      if row.session_refresh_method.blank?
        row.session_refresh_method_name
      else
        auto_link(row.session_refresh_method, row.session_refresh_method_name)
      end
    end

    column :sst_enabled
    column :sst_accept501
    column :sst_session_expires
    column :sst_minimum_timer
    column :sst_maximum_timer

  end
end
