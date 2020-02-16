# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::CdrsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :cdrs
  after { Cdr::Cdr.destroy_all }

  let(:account) { create(:account, contractor: customer) }

  # CDR for the other customer, and not last CDR
  before do
    create_list(:cdr, 2)
    create_list(:cdr, 2, customer_acc: account, is_last_cdr: false)
  end

  describe 'GET /api/rest/customer/v1/cdrs' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end
    let(:json_api_request_query) { nil }

    context 'account_ids is empty' do
      let(:cdrs) { Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true) }
      let(:records_qty) { 2 }

      before { create_list(:cdr, records_qty, customer_acc: account) }

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: cdrs[0].uuid),
            hash_including(id: cdrs[1].uuid)
          ]
        )
      end

      it_behaves_like :json_api_check_pagination do
        let(:records_ids) { cdrs.order(time_start: :desc).map(&:uuid) }
      end
    end

    context 'with account_ids' do
      let(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        api_access.update!(account_ids: allowed_accounts.map(&:id))
        create(:cdr, customer_acc: allowed_accounts[0])
        create(:cdr, customer_acc: allowed_accounts[1])
      end

      let(:cdrs) do
        Cdr::Cdr.where(customer_id: customer.id, customer_acc_id: allowed_accounts.map(&:id), is_last_cdr: true)
      end

      it 'returns CDRs related to allowed_accounts' do
        subject
        expect(response_json[:data]).to match_array(
          [
            hash_including(id: cdrs[0].uuid),
            hash_including(id: cdrs[1].uuid)
          ]
        )
      end
    end

    context 'with filters' do
      let(:json_api_request_query) { { filter: request_filters } }
      let(:cdrs) { Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true) }

      before { create_list(:cdr, 2, customer_acc: account) }
      let(:expected_record) do
        create(:cdr, customer_acc: account, attr_name => attr_value)
      end

      context 'account_id_eq' do
        let(:request_filters) { { account_id_eq: another_account.reload.uuid } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, customer_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.uuid)])
        end
      end

      context 'account_id_not_eq' do
        let(:request_filters) { { account_id_not_eq: account.reload.uuid } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, customer_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.uuid)])
        end
      end

      context 'account_id_in' do
        let(:request_filters) { { account_id_in: "#{another_account.reload.uuid},#{another_account2.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:another_account2) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, customer_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.uuid)])
        end
      end

      context 'account_id_not_in' do
        let(:request_filters) { { account_id_not_in: "#{account.reload.uuid},#{another_account2.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:another_account2) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, customer_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.uuid)])
        end
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
  end

  describe 'GET /api/rest/customer/v1/cdrs/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { cdr.uuid }
    let(:json_api_request_query) { nil }

    before do
      create(:cdr, customer_acc: account)
    end

    let(:cdr) do
      Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true).take
    end

    it_behaves_like :json_api_check_authorization

    it 'returns record with expected attributes' do
      subject
      expect(response_json[:data]).to match(
        id: cdr.uuid,
        'type': 'cdrs',
        'links': anything,
        'relationships': {
          'auth-orig-transport-protocol': {
            'links': anything
          },
          account: {
            'links': anything
          }
        },
        'attributes': {
          'time-start': cdr.time_start.as_json,
          'time-connect': cdr.time_connect.as_json,
          'time-end': cdr.time_end.as_json,
          'duration': cdr.duration,
          'success': cdr.success,
          'destination-initial-interval': cdr.destination_initial_interval,
          'destination-initial-rate': cdr.destination_initial_rate.as_json,
          'destination-next-interval': cdr.destination_next_interval,
          'destination-next-rate': cdr.destination_next_rate.as_json,
          'destination-fee': cdr.destination_fee.as_json,
          'customer-price': cdr.customer_price.as_json,
          'src-name-in': cdr.src_name_in,
          'src-prefix-in': cdr.src_prefix_in,
          'from-domain': cdr.from_domain,
          'dst-prefix-in': cdr.dst_prefix_in,
          'to-domain': cdr.to_domain,
          'ruri-domain': cdr.ruri_domain,
          'diversion-in': cdr.diversion_in,
          'local-tag': cdr.local_tag,
          'lega-disconnect-code': cdr.lega_disconnect_code,
          'lega-disconnect-reason': cdr.lega_disconnect_reason,
          'lega-rx-payloads': cdr.lega_rx_payloads,
          'lega-tx-payloads': cdr.lega_tx_payloads,
          'auth-orig-transport-protocol-id': cdr.auth_orig_transport_protocol_id,
          'auth-orig-ip': cdr.auth_orig_ip,
          'auth-orig-port': cdr.auth_orig_port,
          'lega-rx-bytes': cdr.lega_rx_bytes,
          'lega-tx-bytes': cdr.lega_tx_bytes,
          'lega-rx-decode-errs': cdr.lega_rx_decode_errs,
          'lega-rx-no-buf-errs': cdr.lega_rx_no_buf_errs,
          'lega-rx-parse-errs': cdr.lega_rx_parse_errs,
          'src-prefix-routing': cdr.src_prefix_routing,
          'dst-prefix-routing': cdr.dst_prefix_routing,
          'destination-prefix': cdr.destination_prefix
        }
      )
    end

    context 'with include auth-orig-transport-protocol' do
      let(:json_api_request_query) { { include: 'auth-orig-transport-protocol' } }

      include_examples :returns_json_api_record_relationship, :'auth-orig-transport-protocol' do
        let(:json_api_relationship_data) do
          { id: cdr.auth_orig_transport_protocol_id.to_s, type: 'transport-protocols' }
        end
      end

      include_examples :returns_json_api_record_include, type: :'transport-protocols' do
        let(:json_api_include_id) { cdr.auth_orig_transport_protocol_id.to_s }
        let(:json_api_include_attributes) { { 'name': cdr.auth_orig_transport_protocol.name } }
        let(:json_api_include_relationships_names) { nil }
      end
    end
  end
end
