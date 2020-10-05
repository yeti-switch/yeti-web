# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::GatewaysController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index with contractor filter', type: :request do
    let!(:gateway) { create :gateway }
    let!(:suitable_gateway) { create :gateway }

    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[contractor.id]=#{suitable_gateway.contractor_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end
  FilterType
  describe 'GET index with refresh method filter', type: :request do
    let!(:gateway) { create :gateway }
    let!(:suitable_gateway) { create :gateway, session_refresh_method_id: 2 }

    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[session_refresh_method.id]=#{suitable_gateway.session_refresh_method_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end

  describe 'GET index with sdp alines filter type filter', type: :request do
    let!(:gateway) { create :gateway }
    let!(:filter_types) { create :filter_types } # TODO: fix factory
    let!(:suitable_gateway) { create :gateway, filter_types_id: filter_types.id }
    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[sdp_alines_filter_type.id]=#{suitable_gateway.filter_types_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end

  describe 'GET index with term gateway group filter', type: :request do
    let!(:gateway) { create :gateway }
    let!(:gateway_group) { create :gateway_group }
    let!(:suitable_gateway) { create :gateway, gateway_group_id: gateway_group.id, contractor_id: gateway_group.vendor_id }

    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[gateway_group.id]=#{suitable_gateway.gateway_group_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end

  describe 'GET index with diversion policy filter', type: :request do
    let!(:gateway) { create :gateway }
    # let!(:diversion_policy) { create :diversion_policy }  TODO: create factory

    let!(:suitable_gateway) { create :gateway }

    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[diversion_policy.id]=#{suitable_gateway.diversion_policy_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end

  describe 'GET index with pop filter', type: :request do
    let!(:gateway) { create :gateway }
    let!(:pop) { create :pop }
    let!(:suitable_gateway) { create :gateway, pop_id: pop.id }

    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[pop.id]=#{suitable_gateway.pop_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end

  describe 'GET index with codec group filter', type: :request do
    let!(:gateway) { create :gateway }
    let!(:codec_group) { create :codec_group }
    let!(:suitable_gateway) { create :gateway, codec_group_id: codec_group.id }

    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[codec_group.id]=#{suitable_gateway.codec_group_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end

  describe 'GET index with sensor filter', type: :request do
    let!(:gateway) { create :gateway }
    let!(:sensor) { create :sensor }
    let!(:suitable_gateway) { create :gateway, sensor_id: sensor.id }

    it 'returns only associated records' do
      get "/api/rest/admin/gateways?filter[sensor.id]=#{suitable_gateway.sensor_id}"
      expect(response_data[0]['id']).to eq(suitable_gateway.id.to_s)
    end
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :gateway }
    let(:trait) { :with_incoming_auth }

    it_behaves_like :jsonapi_filters_by_string_field, :host
    it_behaves_like :jsonapi_filters_by_number_field, :port
    it_behaves_like :jsonapi_filters_by_string_field, :src_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :dst_rewrite_rule
    it_behaves_like :jsonapi_filters_by_number_field, :acd_limit
    it_behaves_like :jsonapi_filters_by_number_field, :asr_limit, max_value: 1
    it_behaves_like :jsonapi_filters_by_boolean_field, :enabled
    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_boolean_field, :auth_enabled
    it_behaves_like :jsonapi_filters_by_string_field, :auth_user
    it_behaves_like :jsonapi_filters_by_string_field, :auth_password
    it_behaves_like :jsonapi_filters_by_string_field, :term_outbound_proxy
    it_behaves_like :jsonapi_filters_by_boolean_field, :term_next_hop_for_replies
    it_behaves_like :jsonapi_filters_by_boolean_field, :term_use_outbound_proxy
    it_behaves_like :jsonapi_filters_by_boolean_field, :allow_termination
    it_behaves_like :jsonapi_filters_by_boolean_field, :allow_origination
    it_behaves_like :jsonapi_filters_by_boolean_field, :anonymize_sdp
    it_behaves_like :jsonapi_filters_by_boolean_field, :proxy_media
    it_behaves_like :jsonapi_filters_by_boolean_field, :transparent_seqno
    it_behaves_like :jsonapi_filters_by_boolean_field, :transparent_ssrc
    it_behaves_like :jsonapi_filters_by_boolean_field, :sst_enabled
    it_behaves_like :jsonapi_filters_by_number_field, :sst_minimum_timer
    it_behaves_like :jsonapi_filters_by_number_field, :sst_maximum_timer
    it_behaves_like :jsonapi_filters_by_boolean_field, :sst_accept501
    it_behaves_like :jsonapi_filters_by_number_field, :sst_session_expires
    it_behaves_like :jsonapi_filters_by_boolean_field, :term_force_outbound_proxy
    it_behaves_like :jsonapi_filters_by_boolean_field, :locked
    it_behaves_like :jsonapi_filters_by_string_field, :codecs_payload_order
    it_behaves_like :jsonapi_filters_by_string_field, :codecs_prefer_transcoding_for
    it_behaves_like :jsonapi_filters_by_string_field, :src_rewrite_result
    it_behaves_like :jsonapi_filters_by_string_field, :dst_rewrite_result
    it_behaves_like :jsonapi_filters_by_number_field, :termination_capacity
    it_behaves_like :jsonapi_filters_by_string_field, :term_next_hop
    it_behaves_like :jsonapi_filters_by_string_field, :orig_next_hop
    it_behaves_like :jsonapi_filters_by_string_field, :orig_append_headers_req
    it_behaves_like :jsonapi_filters_by_string_field, :term_append_headers_req
    it_behaves_like :jsonapi_filters_by_boolean_field, :dialog_nat_handling
    it_behaves_like :jsonapi_filters_by_boolean_field, :orig_force_outbound_proxy
    it_behaves_like :jsonapi_filters_by_boolean_field, :orig_use_outbound_proxy
    it_behaves_like :jsonapi_filters_by_string_field, :orig_outbound_proxy
    it_behaves_like :jsonapi_filters_by_boolean_field, :prefer_existing_codecs
    it_behaves_like :jsonapi_filters_by_boolean_field, :force_symmetric_rtp
    it_behaves_like :jsonapi_filters_by_string_field, :sdp_alines_filter_list
    it_behaves_like :jsonapi_filters_by_string_field, :diversion_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :diversion_rewrite_result
    it_behaves_like :jsonapi_filters_by_string_field, :src_name_rewrite_rule
    it_behaves_like :jsonapi_filters_by_string_field, :src_name_rewrite_result
    it_behaves_like :jsonapi_filters_by_number_field, :priority
    it_behaves_like :jsonapi_filters_by_boolean_field, :single_codec_in_200ok
    it_behaves_like :jsonapi_filters_by_number_field, :ringing_timeout
    it_behaves_like :jsonapi_filters_by_boolean_field, :symmetric_rtp_nonstop
    it_behaves_like :jsonapi_filters_by_boolean_field, :symmetric_rtp_ignore_rtcp
    it_behaves_like :jsonapi_filters_by_boolean_field, :resolve_ruri
    it_behaves_like :jsonapi_filters_by_boolean_field, :force_dtmf_relay
    it_behaves_like :jsonapi_filters_by_boolean_field, :relay_options
    it_behaves_like :jsonapi_filters_by_boolean_field, :rtp_ping
    it_behaves_like :jsonapi_filters_by_boolean_field, :filter_noaudio_streams
    it_behaves_like :jsonapi_filters_by_boolean_field, :relay_reinvite
    it_behaves_like :jsonapi_filters_by_string_field, :auth_from_user
    it_behaves_like :jsonapi_filters_by_string_field, :auth_from_domain
    it_behaves_like :jsonapi_filters_by_boolean_field, :relay_hold
    it_behaves_like :jsonapi_filters_by_number_field, :rtp_timeout
    it_behaves_like :jsonapi_filters_by_boolean_field, :relay_prack
    it_behaves_like :jsonapi_filters_by_boolean_field, :rtp_relay_timestamp_aligning
    it_behaves_like :jsonapi_filters_by_boolean_field, :allow_1xx_without_to_tag
    it_behaves_like :jsonapi_filters_by_number_field, :dns_srv_failover_timer
    it_behaves_like :jsonapi_filters_by_boolean_field, :rtp_force_relay_cn
    it_behaves_like :jsonapi_filters_by_boolean_field, :relay_update
    it_behaves_like :jsonapi_filters_by_boolean_field, :suppress_early_media
    it_behaves_like :jsonapi_filters_by_boolean_field, :send_lnp_information
    it_behaves_like :jsonapi_filters_by_number_field, :short_calls_limit, max_value: 1
    it_behaves_like :jsonapi_filters_by_number_field, :origination_capacity
    it_behaves_like :jsonapi_filters_by_boolean_field, :force_one_way_early_media
    it_behaves_like :jsonapi_filters_by_string_field, :transit_headers_from_origination
    it_behaves_like :jsonapi_filters_by_string_field, :transit_headers_from_termination
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
    it_behaves_like :jsonapi_filters_by_number_field, :fake_180_timer
    it_behaves_like :jsonapi_filters_by_string_field, :sip_interface_name
    it_behaves_like :jsonapi_filters_by_string_field, :rtp_interface_name
    it_behaves_like :jsonapi_filters_by_number_field, :rel100_mode_id
    it_behaves_like :jsonapi_filters_by_boolean_field, :is_shared
    it_behaves_like :jsonapi_filters_by_number_field, :max_30x_redirects
    it_behaves_like :jsonapi_filters_by_number_field, :max_transfers
    it_behaves_like :jsonapi_filters_by_string_field, :incoming_auth_username
    it_behaves_like :jsonapi_filters_by_string_field, :incoming_auth_password
    it_behaves_like :jsonapi_filters_by_number_field, :weight
  end
end
