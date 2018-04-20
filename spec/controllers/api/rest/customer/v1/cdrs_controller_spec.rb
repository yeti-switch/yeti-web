require 'spec_helper'

describe Api::Rest::Customer::V1::CdrsController, type: :controller do

  after { Cdr::Cdr.destroy_all }

  let(:api_access) { create(:api_access) }
  let(:customer) { api_access.customer }
  let(:account) { create(:account, contractor: customer) }

  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  # CDR for the other customer, and not last CDR
  before { create_list(:cdr, 2) }
  before { create_list(:cdr, 2, customer_acc: account, is_last_cdr: false) }

  describe 'GET index' do

    context 'account_ids is empty' do
      let(:cdrs) { Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true) }

      before { create_list(:cdr, 2, customer_acc: account) }
      before { get :index }

      it 'returns records of this customer' do
        expect(response.status).to eq(200)
        expect(response_data).to match_array(
          [
            hash_including('id' => cdrs[0].uuid),
            hash_including('id' => cdrs[1].uuid)
          ]
        )
      end
    end

    context 'with account_ids' do
      let(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        api_access.update!(account_ids: allowed_accounts.map(&:id))
        create(:cdr, customer_acc: allowed_accounts[0])
        create(:cdr, customer_acc: allowed_accounts[1])
        get :index
      end

      let(:cdrs) do
        Cdr::Cdr.where(customer_id: customer.id, customer_acc_id: allowed_accounts.map(&:id), is_last_cdr: true)
      end

      it 'returns CDRs related to allowed_accounts' do
        expect(response_data).to match_array(
          [
            hash_including('id' => cdrs[0].uuid),
            hash_including('id' => cdrs[1].uuid)
          ]
        )
      end
    end

  end

  describe 'GET index with filters' do
    let(:cdrs) { Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true) }

    before { create_list(:cdr, 2, customer_acc: account) }
    let(:expected_record) do
      create(:cdr, { customer_acc: account, attr_name => attr_value })
    end

    context 'time_start_gteq and time_start_lteq' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :time_start }
        let(:attr_value) { 25.seconds.ago.utc }
        let(:request_filters) do
          { time_start_gteq: attr_value - 10.seconds, time_start_lteq: attr_value + 10.seconds }
        end
      end
    end

    context 'success' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :success }
        let(:attr_value) { false }
      end
    end

    context 'src_prefix_routing' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :src_prefix_routing }
      end
    end

    context 'dst_prefix_routing' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :dst_prefix_routing }
      end
    end

    context 'duration' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :duration }
        let(:attr_value) { 10 }
      end
    end

    context 'lega_disconnect_code' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :lega_disconnect_code }
        let(:attr_value) { 505 }
      end
    end

    context 'lega_disconnect_reason' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :lega_disconnect_reason }
      end
    end

    context 'src_prefix_in' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :src_prefix_in }
      end
    end

    context 'dst_prefix_in' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :dst_prefix_in }
      end
    end

    context 'diversion_in' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :diversion_in }
      end
    end

    context 'src_name_in' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :src_name_in }
      end
    end

    context 'local_tag' do
      include_examples :jsonapi_request_with_filter do
        let(:attr_name) { :local_tag }
      end
    end
  end

  describe 'GET show' do

    before do
      create(:cdr, customer_acc: account)
    end

    let(:cdr) do
      Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true).take
    end

    it 'returnds record with expected attributes' do
      get :show, params: { id: cdr.uuid }

      expect(response_data).to include({
        'id' => cdr.uuid,
        'type' => 'cdrs',
        'links' => anything,
        'attributes' => {
          'time-start' => cdr.time_start.as_json,
          'time-connect' => cdr.time_connect.as_json,
          'time-end' => cdr.time_end.as_json,
          'duration' => cdr.duration,
          'success' => cdr.success,
          'destination-initial-interval' => cdr.destination_initial_interval,
          'destination-initial-rate' => cdr.destination_initial_rate.as_json,
          'destination-next-interval' => cdr.destination_next_interval,
          'destination-next-rate' => cdr.destination_next_rate.as_json,
          'destination-fee' => cdr.destination_fee.as_json,
          'customer-price' => cdr.customer_price.as_json,
          'src-name-in' => cdr.src_name_in,
          'src-prefix-in' => cdr.src_prefix_in,
          'from-domain' => cdr.from_domain,
          'dst-prefix-in' => cdr.dst_prefix_in,
          'to-domain' => cdr.to_domain,
          'ruri-domain' => cdr.ruri_domain,
          'diversion-in' => cdr.diversion_in,
          'local-tag' => cdr.local_tag,
          'lega-disconnect-code' => cdr.lega_disconnect_code,
          'lega-disconnect-reason' => cdr.lega_disconnect_reason,
          'lega-rx-payloads' => cdr.lega_rx_payloads,
          'lega-tx-payloads' => cdr.lega_tx_payloads,
          'auth-orig-transport-protocol-id' => cdr.auth_orig_transport_protocol_id,
          'auth-orig-ip' => cdr.auth_orig_ip,
          'auth-orig-port' => cdr.auth_orig_port,
          'lega-rx-bytes' => cdr.lega_rx_bytes,
          'lega-tx-bytes' => cdr.lega_tx_bytes,
          'lega-rx-decode-errs' => cdr.lega_rx_decode_errs,
          'lega-rx-no-buf-errs' => cdr.lega_rx_no_buf_errs,
          'lega-rx-parse-errs' => cdr.lega_rx_parse_errs,
          'src-prefix-routing' => cdr.src_prefix_routing,
          'dst-prefix-routing' => cdr.dst_prefix_routing,
          'destination-prefix' => cdr.destination_prefix
        }
      })
    end

    it 'has_one auth-orig-transport-protocol' do
      get :show, params: { id: cdr.uuid, include: 'auth-orig-transport-protocol' }

      expect(JSON.parse(response.body)["included"]).to match_array([
        hash_including({
          'id' => cdr.auth_orig_transport_protocol_id.to_s,
          'type' => 'transport-protocols',
          'links' => anything,
          'attributes' => {
            'name' => cdr.auth_orig_transport_protocol.name
          }
        })
      ])
    end
  end

end
