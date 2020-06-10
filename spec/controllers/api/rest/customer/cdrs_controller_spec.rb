# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CdrsController, type: :controller do
  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:cdrs) { create_list :cdr, 2, customer: customer }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(cdrs.size) }
  end

  describe 'GET index with ransack filters' do
    let(:factory) { :cdr }
    let(:trait) { :with_id_and_uuid }
    let(:factory_attrs) { { customer: customer } }
    let(:pk) { :uuid }

    it_behaves_like :jsonapi_filters_by_datetime_field, :time_start
    it_behaves_like :jsonapi_filters_by_number_field, :destination_next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :destination_fee
    it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_fee
    it_behaves_like :jsonapi_filters_by_string_field, :time_limit
    it_behaves_like :jsonapi_filters_by_number_field, :internal_disconnect_code
    it_behaves_like :jsonapi_filters_by_string_field, :internal_disconnect_reason
    it_behaves_like :jsonapi_filters_by_number_field, :disconnect_initiator_id
    it_behaves_like :jsonapi_filters_by_number_field, :customer_price
    it_behaves_like :jsonapi_filters_by_number_field, :vendor_price
    it_behaves_like :jsonapi_filters_by_number_field, :duration
    it_behaves_like :jsonapi_filters_by_boolean_field, :success
    it_behaves_like :jsonapi_filters_by_number_field, :profit
    it_behaves_like :jsonapi_filters_by_string_field, :dst_prefix_in
    it_behaves_like :jsonapi_filters_by_string_field, :dst_prefix_out
    it_behaves_like :jsonapi_filters_by_string_field, :src_prefix_in
    it_behaves_like :jsonapi_filters_by_string_field, :src_prefix_out
    it_behaves_like :jsonapi_filters_by_datetime_field, :time_connect
    it_behaves_like :jsonapi_filters_by_datetime_field, :time_end
    it_behaves_like :jsonapi_filters_by_string_field, :sign_orig_ip
    it_behaves_like :jsonapi_filters_by_number_field, :sign_orig_port
    it_behaves_like :jsonapi_filters_by_string_field, :sign_orig_local_ip
    it_behaves_like :jsonapi_filters_by_number_field, :sign_orig_local_port
    it_behaves_like :jsonapi_filters_by_string_field, :sign_term_ip
    it_behaves_like :jsonapi_filters_by_number_field, :sign_term_port
    it_behaves_like :jsonapi_filters_by_string_field, :sign_term_local_ip
    it_behaves_like :jsonapi_filters_by_number_field, :sign_term_local_port
    it_behaves_like :jsonapi_filters_by_string_field, :orig_call_id
    it_behaves_like :jsonapi_filters_by_string_field, :term_call_id
    it_behaves_like :jsonapi_filters_by_number_field, :vendor_invoice_id
    it_behaves_like :jsonapi_filters_by_number_field, :customer_invoice_id
    it_behaves_like :jsonapi_filters_by_string_field, :local_tag
    it_behaves_like :jsonapi_filters_by_number_field, :destination_initial_rate
    it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_initial_rate
    it_behaves_like :jsonapi_filters_by_number_field, :destination_initial_interval
    it_behaves_like :jsonapi_filters_by_number_field, :destination_next_interval
    it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_initial_interval
    it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_next_interval
    it_behaves_like :jsonapi_filters_by_number_field, :routing_attempt
    it_behaves_like :jsonapi_filters_by_number_field, :lega_disconnect_code
    it_behaves_like :jsonapi_filters_by_string_field, :lega_disconnect_reason
    it_behaves_like :jsonapi_filters_by_number_field, :node_id
    it_behaves_like :jsonapi_filters_by_string_field, :src_name_in
    it_behaves_like :jsonapi_filters_by_string_field, :src_name_out
    it_behaves_like :jsonapi_filters_by_string_field, :diversion_in
    it_behaves_like :jsonapi_filters_by_string_field, :diversion_out
    it_behaves_like :jsonapi_filters_by_string_field, :lega_rx_payloads
    it_behaves_like :jsonapi_filters_by_string_field, :lega_tx_payloads
    it_behaves_like :jsonapi_filters_by_string_field, :legb_rx_payloads
    it_behaves_like :jsonapi_filters_by_string_field, :legb_tx_payloads
    it_behaves_like :jsonapi_filters_by_number_field, :legb_disconnect_code
    it_behaves_like :jsonapi_filters_by_string_field, :legb_disconnect_reason
    it_behaves_like :jsonapi_filters_by_number_field, :dump_level_id
    it_behaves_like :jsonapi_filters_by_inet_field, :auth_orig_ip
    it_behaves_like :jsonapi_filters_by_number_field, :auth_orig_port
    it_behaves_like :jsonapi_filters_by_number_field, :lega_rx_bytes
    it_behaves_like :jsonapi_filters_by_number_field, :lega_tx_bytes
    it_behaves_like :jsonapi_filters_by_number_field, :legb_rx_bytes
    it_behaves_like :jsonapi_filters_by_number_field, :legb_tx_bytes
    it_behaves_like :jsonapi_filters_by_string_field, :global_tag
    it_behaves_like :jsonapi_filters_by_number_field, :dst_country_id
    it_behaves_like :jsonapi_filters_by_number_field, :dst_network_id
    it_behaves_like :jsonapi_filters_by_number_field, :lega_rx_decode_errs
    it_behaves_like :jsonapi_filters_by_number_field, :lega_rx_no_buf_errs
    it_behaves_like :jsonapi_filters_by_number_field, :lega_rx_parse_errs
    it_behaves_like :jsonapi_filters_by_number_field, :legb_rx_decode_errs
    it_behaves_like :jsonapi_filters_by_number_field, :legb_rx_no_buf_errs
    it_behaves_like :jsonapi_filters_by_number_field, :legb_rx_parse_errs
    it_behaves_like :jsonapi_filters_by_string_field, :src_prefix_routing
    it_behaves_like :jsonapi_filters_by_string_field, :dst_prefix_routing
    it_behaves_like :jsonapi_filters_by_number_field, :routing_delay
    it_behaves_like :jsonapi_filters_by_number_field, :pdd
    it_behaves_like :jsonapi_filters_by_number_field, :rtt
    it_behaves_like :jsonapi_filters_by_boolean_field, :early_media_present
    it_behaves_like :jsonapi_filters_by_number_field, :lnp_database_id
    it_behaves_like :jsonapi_filters_by_string_field, :lrn
    it_behaves_like :jsonapi_filters_by_string_field, :destination_prefix
    it_behaves_like :jsonapi_filters_by_string_field, :dialpeer_prefix
    it_behaves_like :jsonapi_filters_by_boolean_field, :audio_recorded
    it_behaves_like :jsonapi_filters_by_string_field, :ruri_domain
    it_behaves_like :jsonapi_filters_by_string_field, :to_domain
    it_behaves_like :jsonapi_filters_by_string_field, :from_domain
    it_behaves_like :jsonapi_filters_by_number_field, :src_area_id
    it_behaves_like :jsonapi_filters_by_number_field, :dst_area_id
    it_behaves_like :jsonapi_filters_by_number_field, :auth_orig_transport_protocol_id
    it_behaves_like :jsonapi_filters_by_number_field, :sign_orig_transport_protocol_id
    it_behaves_like :jsonapi_filters_by_number_field, :sign_term_transport_protocol_id
    it_behaves_like :jsonapi_filters_by_string_field, :core_version
    it_behaves_like :jsonapi_filters_by_string_field, :yeti_version
    it_behaves_like :jsonapi_filters_by_string_field, :lega_user_agent
    it_behaves_like :jsonapi_filters_by_string_field, :legb_user_agent
    it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
    it_behaves_like :jsonapi_filters_by_string_field, :pai_in
    it_behaves_like :jsonapi_filters_by_string_field, :ppi_in
    it_behaves_like :jsonapi_filters_by_string_field, :privacy_in
    it_behaves_like :jsonapi_filters_by_string_field, :rpid_in
    it_behaves_like :jsonapi_filters_by_string_field, :rpid_privacy_in
    it_behaves_like :jsonapi_filters_by_string_field, :pai_out
    it_behaves_like :jsonapi_filters_by_string_field, :ppi_out
    it_behaves_like :jsonapi_filters_by_string_field, :privacy_out
    it_behaves_like :jsonapi_filters_by_string_field, :rpid_out
    it_behaves_like :jsonapi_filters_by_string_field, :rpid_privacy_out
    it_behaves_like :jsonapi_filters_by_boolean_field, :destination_reverse_billing
    it_behaves_like :jsonapi_filters_by_boolean_field, :dialpeer_reverse_billing
    it_behaves_like :jsonapi_filters_by_boolean_field, :is_redirected
    it_behaves_like :jsonapi_filters_by_boolean_field, :customer_account_check_balance
    it_behaves_like :jsonapi_filters_by_number_field, :customer_external_id
    it_behaves_like :jsonapi_filters_by_number_field, :customer_auth_external_id
    it_behaves_like :jsonapi_filters_by_number_field, :customer_acc_vat
    it_behaves_like :jsonapi_filters_by_number_field, :customer_acc_external_id
    it_behaves_like :jsonapi_filters_by_number_field, :vendor_external_id
    it_behaves_like :jsonapi_filters_by_number_field, :vendor_acc_external_id
    it_behaves_like :jsonapi_filters_by_number_field, :orig_gw_external_id
    it_behaves_like :jsonapi_filters_by_number_field, :term_gw_external_id
    it_behaves_like :jsonapi_filters_by_number_field, :failed_resource_type_id
    it_behaves_like :jsonapi_filters_by_number_field, :failed_resource_id
    it_behaves_like :jsonapi_filters_by_number_field, :customer_price_no_vat
    it_behaves_like :jsonapi_filters_by_number_field, :customer_duration
    it_behaves_like :jsonapi_filters_by_number_field, :vendor_duration
  end
end
