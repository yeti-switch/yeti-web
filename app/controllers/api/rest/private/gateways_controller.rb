class Api::Rest::Private::GatewaysController < Api::RestController

  after_action only: [:index] do
    send_x_headers(@gateways)
  end

  before_action only: [:show, :update, :destroy] do
    @gateway = Gateway.find(params[:id])
  end


  def index
    @gateways = resource_collection(Gateway.all)
    respond_with(@gateways)
  end

  def show
    respond_with(@gateway, location: nil)
  end

  def create
    @gateway = Gateway.create(gateway_params)
    respond_with(@gateway, location: nil)
  end

  def update
    @gateway.update(gateway_params)
    respond_with(@gateway, location: nil)
  end

  def destroy
    @gateway.destroy!
    respond_with(@gateway, location: nil)
  end

  private

  def gateway_params
    params.require(:gateway).permit(
      :name,
      :enabled,
      :priority,
      :acd_limit,
      :asr_limit,
      :contractor_id,
      :sdp_alines_filter_type_id,
      :codec_group_id,
      :sdp_c_location_id,
      :sensor_level_id,
      :dtmf_receive_mode_id,
      :dtmf_send_mode_id,
      :rel100_mode_id,
      :session_refresh_method_id,
      :transport_protocol_id,
      :term_proxy_transport_protocol_id,
      :orig_proxy_transport_protocol_id,
      :gateway_group_id,
      :pop_id,
      :allow_origination,
      :allow_termination,
      :sst_enabled,
      :sensor_id,
      :host,
      :port,
      :resolve_ruri,
      :diversion_policy_id,
      :diversion_rewrite_rule,
      :diversion_rewrite_result,
      :src_name_rewrite_rule,
      :src_name_rewrite_result,
      :src_rewrite_rule,
      :src_rewrite_result,
      :dst_rewrite_rule,
      :dst_rewrite_result,
      :auth_enabled,
      :auth_user,
      :auth_password,
      :auth_from_user,
      :auth_from_domain,
      :term_use_outbound_proxy,
      :term_force_outbound_proxy,
      :term_outbound_proxy,
      :term_next_hop_for_replies,
      :term_next_hop,
      :term_disconnect_policy_id,
      :term_append_headers_req,
      :sdp_alines_filter_list,
      :ringing_timeout,
      :relay_options,
      :relay_reinvite,
      :relay_hold,
      :relay_prack,
      :relay_update,
      :suppress_early_media,
      :fake_180_timer,
      :transit_headers_from_origination,
      :transit_headers_from_termination,
      :sip_interface_name,
      :allow_1xx_without_to_tag,
      :sip_timer_b,
      :dns_srv_failover_timer,
      :anonymize_sdp,
      :proxy_media,
      :single_codec_in_200ok,
      :transparent_seqno,
      :transparent_ssrc,
      :force_symmetric_rtp,
      :symmetric_rtp_nonstop,
      :symmetric_rtp_ignore_rtcp,
      :force_dtmf_relay,
      :rtp_ping,
      :rtp_timeout,
      :filter_noaudio_streams,
      :rtp_relay_timestamp_aligning,
      :rtp_force_relay_cn
    )
  end
end
