# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::IncomingCdrsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'incoming-cdrs'

  let(:account) { create(:account, contractor: customer) }

  # CDR for the other customer
  before do
    create_list(:cdr, 2)
  end

  describe 'GET /api/rest/customer/v1/incoming-cdrs' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end
    let(:json_api_request_query) { nil }

    it_behaves_like :json_api_customer_v1_check_authorization

    context 'account_ids is empty' do
      let(:cdrs) { Cdr::Cdr.where(vendor_id: customer.id) }
      let(:records_qty) { 2 }

      before { create_list(:cdr, records_qty, vendor_acc: account) }

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data]).to match_array(
                                          [
                                            hash_including(id: cdrs[0].id.to_s),
                                            hash_including(id: cdrs[1].id.to_s)
                                          ]
                                        )
      end

      it_behaves_like :json_api_check_pagination do
        let(:records_ids) { cdrs.order(time_start: :desc).map { |c| c.id.to_s } }
      end
    end

    context 'with account_ids' do
      let(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        api_access.update!(account_ids: allowed_accounts.map(&:id))
        create(:cdr, vendor_acc: allowed_accounts[0])
        create(:cdr, vendor_acc: allowed_accounts[1])
      end

      let(:cdrs) do
        Cdr::Cdr.where(vendor_id: customer.id, vendor_acc_id: allowed_accounts.map(&:id), is_last_cdr: true)
      end

      it 'returns CDRs related to allowed_accounts' do
        subject
        expect(response_json[:data]).to match_array(
                                          [
                                            hash_including(id: cdrs[0].id.to_s),
                                            hash_including(id: cdrs[1].id.to_s)
                                          ]
                                        )
      end
    end

    context 'with filters by account' do
      let(:json_api_request_query) { { filter: request_filters } }
      let(:cdrs) { Cdr::Cdr.where(vendor_id: customer.id, is_last_cdr: true) }

      before { create_list(:cdr, 2, vendor_acc: account) }
      let(:expected_record) do
        create(:cdr, vendor_acc: account, attr_name => attr_value)
      end

      context 'account_id_eq' do
        let(:request_filters) { { account_id_eq: another_account.reload.uuid } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, vendor_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end

      context 'account_id_not_eq' do
        let(:request_filters) { { account_id_not_eq: account.reload.uuid } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, vendor_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end

      context 'account_id_in' do
        let(:request_filters) { { account_id_in: "#{another_account.reload.uuid},#{another_account2.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:another_account2) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, vendor_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end

      context 'account_id_not_in' do
        let(:request_filters) { { account_id_not_in: "#{account.reload.uuid},#{another_account2.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:another_account2) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, vendor_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end
    end

    context 'with ransack filters' do
      let(:factory) { :cdr }
      let(:trait) { :with_id_and_uuid }
      let(:factory_attrs) { { vendor: customer } }
      let(:pk) { :id }

      it_behaves_like :jsonapi_filters_by_number_field, :id
      it_behaves_like :jsonapi_filters_by_datetime_field, :time_start
      it_behaves_like :jsonapi_filters_by_datetime_field, :time_connect
      it_behaves_like :jsonapi_filters_by_datetime_field, :time_end
      it_behaves_like :jsonapi_filters_by_number_field, :duration
      it_behaves_like :jsonapi_filters_by_boolean_field, :success

      it_behaves_like :jsonapi_filters_by_number_field, :legb_disconnect_code
      it_behaves_like :jsonapi_filters_by_string_field, :legb_disconnect_reason

      it_behaves_like :jsonapi_filters_by_string_field, :dst_prefix_out
      it_behaves_like :jsonapi_filters_by_string_field, :src_prefix_out
      it_behaves_like :jsonapi_filters_by_string_field, :src_name_out
      it_behaves_like :jsonapi_filters_by_string_field, :src_prefix_routing
      it_behaves_like :jsonapi_filters_by_string_field, :dst_prefix_routing
      it_behaves_like :jsonapi_filters_by_string_field, :diversion_out

      it_behaves_like :jsonapi_filters_by_string_field, :local_tag
      it_behaves_like :jsonapi_filters_by_string_field, :dialpeer_prefix
      it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_initial_rate
      it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_next_rate
      it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_fee
      it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_initial_interval
      it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_next_interval
      it_behaves_like :jsonapi_filters_by_boolean_field, :dialpeer_reverse_billing
      it_behaves_like :jsonapi_filters_by_number_field, :vendor_price
      it_behaves_like :jsonapi_filters_by_number_field, :vendor_duration

      it_behaves_like :jsonapi_filters_by_string_field, :legb_user_agent
    end

    context 'with include account' do
      let!(:cdrs) do
        create_list(:cdr, 2, vendor_acc: account)
        Cdr::Cdr.where(vendor_id: customer.id).to_a
      end
      let(:json_api_request_query) do
        { include: 'account' }
      end

      it 'responds with included accounts' do
        subject
        cdrs.each do |cdr|
          data = response_json[:data].detect { |item| item[:id] == cdr.id.to_s }
          expect(data[:relationships][:account][:data]).to eq(
                                                             id: cdr.vendor_acc.uuid,
                                                             type: 'accounts'
                                                           )
        end
        cdrs_accounts = cdrs.map(&:vendor_acc).uniq
        expect(response_json[:included]).to match_array(
                                              cdrs_accounts.map do |account|
                                                hash_including(id: account.uuid, type: 'accounts')
                                              end
                                            )
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |data| data[:id] }
        expect(actual_ids).to match_array cdrs.map { |c| c.id.to_s }
      end
    end
  end

  describe 'GET /api/rest/customer/v1/incoming-cdrs/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { cdr.id }
    let(:json_api_request_query) { nil }

    let!(:cdr) { create(:cdr, :with_id, cdr_attrs).reload }
    let(:cdr_attrs) { { vendor_acc: account } }

    it_behaves_like :json_api_customer_v1_check_authorization

    it 'returns record with expected attributes' do
      subject
      expect(response_json[:data]).to match(
                                        id: cdr.id.to_s,
                                        'type': 'incoming-cdrs',
                                        'links': anything,
                                        'relationships': {
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
                                          'dialpeer-prefix': cdr.dialpeer_prefix,
                                          'dialpeer-initial-interval': cdr.dialpeer_initial_interval,
                                          'dialpeer-initial-rate': cdr.dialpeer_initial_rate.as_json,
                                          'dialpeer-next-interval': cdr.dialpeer_next_interval,
                                          'dialpeer-next-rate': cdr.dialpeer_next_rate.as_json,
                                          'dialpeer-fee': cdr.dialpeer_fee.as_json,
                                          'vendor-price': cdr.vendor_price.as_json,
                                          'vendor-duration': cdr.vendor_duration,
                                          'src-name-out': cdr.src_name_out,
                                          'src-prefix-out': cdr.src_prefix_out,
                                          'dst-prefix-out': cdr.dst_prefix_out,
                                          'diversion-out': cdr.diversion_out,
                                          'local-tag': cdr.local_tag,
                                          'legb-disconnect-code': cdr.legb_disconnect_code,
                                          'legb-disconnect-reason': cdr.legb_disconnect_reason,
                                          'src-prefix-routing': cdr.src_prefix_routing,
                                          'dst-prefix-routing': cdr.dst_prefix_routing,
                                          'legb-user-agent': cdr.legb_user_agent,
                                          'sign-term-ip': cdr.sign_term_ip,
                                          'sign-term-port': cdr.sign_term_port,
                                          'sign-term-transport-protocol-id': cdr.sign_term_transport_protocol_id,
                                          'term-call-id': cdr.term_call_id,
                                          rec: false
                                        }
                                      )
    end

    context 'with include account' do
      let(:json_api_request_query) { { include: 'account' } }

      include_examples :returns_json_api_record_relationship, :account do
        let(:json_api_relationship_data) do
          { id: cdr.vendor_acc.uuid, type: 'accounts' }
        end
      end

      include_examples :returns_json_api_record_include, type: :accounts do
        let(:json_api_include_id) { cdr.vendor_acc.uuid }
        let(:json_api_include_attributes) {
          {
            'name': cdr.vendor_acc.name,
            'balance': cdr.vendor_acc.balance.to_s,
            'max-balance': cdr.vendor_acc.max_balance.to_s,
            'min-balance': cdr.vendor_acc.min_balance.to_s,
            'destination-rate-limit': cdr.vendor_acc.destination_rate_limit.to_s,
            'origination-capacity': cdr.vendor_acc.origination_capacity,
            'termination-capacity': cdr.vendor_acc.termination_capacity,
            'total-capacity': cdr.vendor_acc.total_capacity
          }
        }
        let(:json_api_include_relationships_names) { nil }
      end
    end

    context 'when api_access.allow_listen_recording=true' do
      before { api_access.update!(allow_listen_recording: true) }

      context 'when cdr audio recorded successfully' do
        let(:cdr_attrs) do
          super().merge audio_recorded: true,
                        local_tag: SecureRandom.uuid,
                        duration: 123
        end

        it 'responds with attribute rec=true' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq true
        end
      end

      context 'when cdr audio not recorded' do
        let(:cdr_attrs) do
          super().merge audio_recorded: false,
                        local_tag: SecureRandom.uuid,
                        duration: 123
        end

        it 'responds with attribute rec=false' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq false
        end
      end

      context 'when cdr has no local_tag' do
        let(:cdr_attrs) do
          super().merge audio_recorded: true,
                        local_tag: nil,
                        duration: 123
        end

        it 'responds with attribute rec=false' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq false
        end
      end

      context 'when cdr has duration 0' do
        let(:cdr_attrs) do
          super().merge audio_recorded: true,
                        local_tag: SecureRandom.uuid,
                        duration: 0
        end

        it 'responds with attribute rec=false' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq false
        end
      end
    end

    context 'when api_access.allow_listen_recording=false' do
      before { api_access.update!(allow_listen_recording: false) }

      context 'when cdr audio recorded successfully' do
        let(:cdr_attrs) do
          super().merge audio_recorded: true,
                        local_tag: SecureRandom.uuid,
                        duration: 123
        end

        it 'responds with attribute rec=false' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq false
        end
      end

      context 'when cdr audio not recorded' do
        let(:cdr_attrs) do
          super().merge audio_recorded: false,
                        local_tag: SecureRandom.uuid,
                        duration: 123
        end

        it 'responds with attribute rec=false' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq false
        end
      end

      context 'when cdr has no local_tag' do
        let(:cdr_attrs) do
          super().merge audio_recorded: true,
                        local_tag: nil,
                        duration: 123
        end

        it 'responds with attribute rec=false' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq false
        end
      end

      context 'when cdr has duration 0' do
        let(:cdr_attrs) do
          super().merge audio_recorded: true,
                        local_tag: SecureRandom.uuid,
                        duration: 0
        end

        it 'responds with attribute rec=false' do
          subject
          expect(response_json[:data][:attributes][:rec]).to eq false
        end
      end
    end
  end

  describe 'GET /api/rest/customer/v1/incoming-cdrs/:id/rec' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    shared_examples :responds_404 do
      it 'responds 404' do
        subject
        expect(response.status).to eq 404
        expect(response.body).to be_blank
        expect(response.headers['X-Accel-Redirect']).to be_nil
        expect(response.headers['Content-Disposition']).to be_nil
      end
    end

    before { api_access.update!(allow_listen_recording:) }

    let(:allow_listen_recording) { true }
    let(:json_api_request_path) { "#{super()}/#{record_id}/rec" }
    let(:record_id) { cdr.id }
    let!(:cdr) { create(:cdr, :with_id, cdr_attrs).reload }
    let(:cdr_attrs) do
      { vendor_acc: account, audio_recorded: true, local_tag: SecureRandom.uuid, duration: 12 }
    end

    it 'responds with X-Accel-Redirect' do
      subject
      expect(response.status).to eq 200
      expect(response.body).to be_blank
      expect(response.headers['X-Accel-Redirect']).to eq cdr.call_record_filename
      expect(response.headers['Content-Type']).to eq cdr.call_record_ct
    end

    context 'when cdr audio not recorded' do
      let(:cdr_attrs) do
        super().merge audio_recorded: false
      end

      include_examples :responds_404
    end

    context 'when cdr has no local_tag' do
      let(:cdr_attrs) do
        super().merge local_tag: nil
      end

      include_examples :responds_404
    end

    context 'when cdr has duration 0' do
      let(:cdr_attrs) do
        super().merge duration: 0
      end

      include_examples :responds_404
    end

    context 'when api_access.allow_listen_recording=false' do
      let(:allow_listen_recording) { false }

      include_examples :responds_404
    end

    context 'with invalid ID' do
      let(:record_id) { -1000 }

      include_examples :returns_json_api_errors, status: 404, errors: {
        title: 'Record not found'
      }
    end

    context 'when customer allowed_account_ids does not include cdr_export account' do
      let!(:allowed_account) { FactoryBot.create(:account, contractor: customer) }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      include_examples :returns_json_api_errors, status: 404, errors: {
        title: 'Record not found'
      }
    end
  end
end
