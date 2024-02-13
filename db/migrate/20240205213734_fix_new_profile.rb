class FixNewProfile < ActiveRecord::Migration[7.0]

  def down
    execute %q{

CREATE or replace FUNCTION switch20.new_profile() RETURNS switch20.callprofile_ty
    LANGUAGE plpgsql COST 10
    AS $_$
DECLARE
  v_ret switch20.callprofile_ty;
BEGIN
  --v_ret.append_headers:='Max-Forwards: 70\r\n';
  v_ret.enable_auth:=false;
  v_ret.auth_user:='';
  v_ret.auth_pwd:='';
  v_ret.enable_aleg_auth:=false;
  v_ret.auth_aleg_user:='';
  v_ret.auth_aleg_pwd:='';
  v_ret.call_id:='$ci_leg43';

  v_ret.force_outbound_proxy:=false;
  v_ret.outbound_proxy:='';
  v_ret.next_hop:='';
  --    v_ret.next_hop_for_replies:='';
  v_ret.next_hop_1st_req:=false;

  v_ret.sdp_filter_type_id:=0; -- transparent
  v_ret.sdp_filter_list:='';
  v_ret.sdp_alines_filter_type_id:=0; -- transparent
  v_ret.sdp_alines_filter_list:='';

  v_ret.enable_session_timer:=false;
  v_ret.session_expires ='150';
  v_ret.minimum_timer:='30';
  v_ret.minimum_timer:='60';
  v_ret.session_refresh_method_id:=1;
  v_ret.accept_501_reply:=true;
  v_ret.enable_aleg_session_timer=false;
  v_ret.aleg_session_expires:='180';
  v_ret.aleg_minimum_timer:='30';
  v_ret.aleg_maximum_timer:='60';
  v_ret.aleg_session_refresh_method_id:=1;
  v_ret.aleg_accept_501_reply:='';
  v_ret.reply_translations:='';

  v_ret.enable_rtprelay:=false;

  v_ret.rtprelay_interface:='';
  v_ret.aleg_rtprelay_interface:='';
  v_ret.outbound_interface:='';

  v_ret.try_avoid_transcoding:=FALSE;

  v_ret.rtprelay_dtmf_filtering:=TRUE;
  v_ret.rtprelay_dtmf_detection:=TRUE;
  v_ret.rtprelay_force_dtmf_relay:=FALSE;

  v_ret.patch_ruri_next_hop:=FALSE;

  v_ret.aleg_force_symmetric_rtp:=TRUE;
  v_ret.bleg_force_symmetric_rtp:=TRUE;

  v_ret.aleg_symmetric_rtp_nonstop:=FALSE;
  v_ret.bleg_symmetric_rtp_nonstop:=FALSE;

  v_ret.aleg_symmetric_rtp_ignore_rtcp:=TRUE;
  v_ret.bleg_symmetric_rtp_ignore_rtcp:=TRUE;

  v_ret.aleg_rtp_ping:=FALSE;
  v_ret.bleg_rtp_ping:=FALSE;

  v_ret.aleg_relay_options:=FALSE;
  v_ret.bleg_relay_options:=FALSE;

  v_ret.filter_noaudio_streams:=FALSE;

  /* enum conn_location {
   *   BOTH = 0,
   *   SESSION_ONLY,
   *   MEDIA_ONLY
   * } */
  v_ret.aleg_sdp_c_location_id:=0; --BOTH
  v_ret.bleg_sdp_c_location_id:=0; --BOTH

  v_ret.trusted_hdrs_gw:=FALSE;

  --v_ret.aleg_append_headers_reply:='';
  --v_ret.aleg_append_headers_reply=E'X-VND-INIT-INT:60\r\nX-VND-NEXT-INT:60\r\nX-VND-INIT-RATE:0\r\nX-VND-NEXT-RATE:0\r\nX-VND-CF:0';


  /*
   *  #define FILTER_TYPE_TRANSPARENT     0
   *  #define FILTER_TYPE_BLACKLIST       1
   *  #define FILTER_TYPE_WHITELIST       2
   */
  v_ret.bleg_sdp_alines_filter_list:='';
  v_ret.bleg_sdp_alines_filter_type_id:=0; --FILTER_TYPE_TRANSPARENT

  RETURN v_ret;
END;
$_$;

    }
  end


  def up
    execute %q{

CREATE or replace FUNCTION switch20.new_profile() RETURNS switch20.callprofile_ty
    LANGUAGE plpgsql COST 10
    AS $_$
DECLARE
  v_ret switch20.callprofile_ty;
BEGIN
  --v_ret.append_headers:='Max-Forwards: 70\r\n';
  v_ret.enable_auth:=false;
  v_ret.auth_user:='';
  v_ret.auth_pwd:='';
  v_ret.enable_aleg_auth:=false;
  v_ret.auth_aleg_user:='';
  v_ret.auth_aleg_pwd:='';
  v_ret.call_id:='$ci_leg43';
  --    v_ret.contact:='<sip:$Ri>';
  v_ret."from":='$f';
  v_ret."to":='$t';
  v_ret.ruri:='$r';
  v_ret.force_outbound_proxy:=false;
  v_ret.outbound_proxy:='';
  v_ret.next_hop:='';
  --    v_ret.next_hop_for_replies:='';
  v_ret.next_hop_1st_req:=false;

  v_ret.sdp_filter_type_id:=0; -- transparent
  v_ret.sdp_filter_list:='';
  v_ret.sdp_alines_filter_type_id:=0; -- transparent
  v_ret.sdp_alines_filter_list:='';

  v_ret.enable_session_timer:=false;
  v_ret.session_expires ='150';
  v_ret.minimum_timer:='30';
  v_ret.minimum_timer:='60';
  v_ret.session_refresh_method_id:=1;
  v_ret.accept_501_reply:=true;
  v_ret.enable_aleg_session_timer=false;
  v_ret.aleg_session_expires:='180';
  v_ret.aleg_minimum_timer:='30';
  v_ret.aleg_maximum_timer:='60';
  v_ret.aleg_session_refresh_method_id:=1;
  v_ret.aleg_accept_501_reply:='';
  v_ret.reply_translations:='';

  v_ret.enable_rtprelay:=false;

  v_ret.rtprelay_interface:='';
  v_ret.aleg_rtprelay_interface:='';
  v_ret.outbound_interface:='';

  v_ret.try_avoid_transcoding:=FALSE;

  v_ret.rtprelay_dtmf_filtering:=TRUE;
  v_ret.rtprelay_dtmf_detection:=TRUE;
  v_ret.rtprelay_force_dtmf_relay:=FALSE;

  v_ret.patch_ruri_next_hop:=FALSE;

  v_ret.aleg_force_symmetric_rtp:=TRUE;
  v_ret.bleg_force_symmetric_rtp:=TRUE;

  v_ret.aleg_symmetric_rtp_nonstop:=FALSE;
  v_ret.bleg_symmetric_rtp_nonstop:=FALSE;

  v_ret.aleg_symmetric_rtp_ignore_rtcp:=TRUE;
  v_ret.bleg_symmetric_rtp_ignore_rtcp:=TRUE;

  v_ret.aleg_rtp_ping:=FALSE;
  v_ret.bleg_rtp_ping:=FALSE;

  v_ret.aleg_relay_options:=FALSE;
  v_ret.bleg_relay_options:=FALSE;

  v_ret.filter_noaudio_streams:=FALSE;

  /* enum conn_location {
   *   BOTH = 0,
   *   SESSION_ONLY,
   *   MEDIA_ONLY
   * } */
  v_ret.aleg_sdp_c_location_id:=0; --BOTH
  v_ret.bleg_sdp_c_location_id:=0; --BOTH

  v_ret.trusted_hdrs_gw:=FALSE;

  --v_ret.aleg_append_headers_reply:='';
  --v_ret.aleg_append_headers_reply=E'X-VND-INIT-INT:60\r\nX-VND-NEXT-INT:60\r\nX-VND-INIT-RATE:0\r\nX-VND-NEXT-RATE:0\r\nX-VND-CF:0';


  /*
   *  #define FILTER_TYPE_TRANSPARENT     0
   *  #define FILTER_TYPE_BLACKLIST       1
   *  #define FILTER_TYPE_WHITELIST       2
   */
  v_ret.bleg_sdp_alines_filter_list:='';
  v_ret.bleg_sdp_alines_filter_type_id:=0; --FILTER_TYPE_TRANSPARENT

  RETURN v_ret;
END;
$_$;

    }
  end


end
