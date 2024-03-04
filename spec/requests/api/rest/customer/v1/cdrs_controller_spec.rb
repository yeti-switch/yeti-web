# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CdrsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :cdrs

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

    it_behaves_like :json_api_customer_v1_check_authorization

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

      context 'is_last_cdr false' do
        let(:request_filters) { { is_last_cdr: false } }
        let!(:expected_record) { create(:cdr, customer_acc: account, is_last_cdr: false) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array(
            Cdr::Cdr.where(is_last_cdr: false).map do |r|
              hash_including(id: r.uuid)
            end
          )
        end
      end
    end

    context 'with ransack filters' do
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
      it_behaves_like :jsonapi_filters_by_number_field, :legb_disconnect_code
      it_behaves_like :jsonapi_filters_by_string_field, :legb_disconnect_reason
      it_behaves_like :jsonapi_filters_by_number_field, :dump_level_id
      it_behaves_like :jsonapi_filters_by_inet_field, :auth_orig_ip
      it_behaves_like :jsonapi_filters_by_number_field, :auth_orig_port
      it_behaves_like :jsonapi_filters_by_string_field, :global_tag
      it_behaves_like :jsonapi_filters_by_number_field, :dst_country_id
      it_behaves_like :jsonapi_filters_by_number_field, :dst_network_id
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

    context 'with include account' do
      let!(:cdrs) do
        create_list(:cdr, 2, customer_acc: account)
        Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true).to_a
      end
      let(:json_api_request_query) do
        { include: 'account' }
      end

      it 'responds with included accounts' do
        subject
        cdrs.each do |cdr|
          data = response_json[:data].detect { |item| item[:id] == cdr.uuid }
          expect(data[:relationships][:account][:data]).to eq(
                                                             id: cdr.customer_acc.uuid,
                                                             type: 'accounts'
                                                           )
        end
        cdrs_accounts = cdrs.map(&:customer_acc).uniq
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
        expect(actual_ids).to match_array cdrs.map(&:uuid)
      end
    end

    context 'with include auth-orig-transport-protocol' do
      let!(:cdrs) do
        create_list(:cdr, 2, customer_acc: account)
        Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true).to_a
      end
      let(:json_api_request_query) do
        { include: 'auth-orig-transport-protocol' }
      end

      it 'responds with included transport-protocols' do
        subject
        cdrs.each do |cdr|
          data = response_json[:data].detect { |item| item[:id] == cdr.uuid }
          expect(data[:relationships][:'auth-orig-transport-protocol'][:data]).to eq(
                                                             id: cdr.auth_orig_transport_protocol.id.to_s,
                                                             type: 'transport-protocols'
                                                           )
        end
        cdrs_transport_protocols = cdrs.map(&:auth_orig_transport_protocol).uniq
        expect(response_json[:included]).to match_array(
                                              cdrs_transport_protocols.map do |transport_protocol|
                                                hash_including(id: transport_protocol.id.to_s, type: 'transport-protocols')
                                              end
                                            )
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].map { |data| data[:id] }
        expect(actual_ids).to match_array cdrs.map(&:uuid)
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

    let!(:cdr) { create(:cdr, :with_id, cdr_attrs).reload }
    let(:cdr_attrs) { { customer_acc: account } }

    it_behaves_like :json_api_customer_v1_check_authorization

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
          'auth-orig-transport-protocol-id': cdr.auth_orig_transport_protocol_id,
          'auth-orig-ip': cdr.auth_orig_ip,
          'auth-orig-port': cdr.auth_orig_port,
          'src-prefix-routing': cdr.src_prefix_routing,
          'dst-prefix-routing': cdr.dst_prefix_routing,
          'destination-prefix': cdr.destination_prefix,
          rec: false
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

  describe 'GET /api/rest/customer/v1/cdrs/:id/rec' do
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
    let(:record_id) { cdr.uuid }
    let!(:cdr) { create(:cdr, :with_id, cdr_attrs).reload }
    let(:cdr_attrs) do
      { customer_acc: account, audio_recorded: true, local_tag: SecureRandom.uuid, duration: 12 }
    end

    it 'responds with X-Accel-Redirect' do
      subject
      expect(response.status).to eq 200
      expect(response.body).to be_blank
      expect(response.headers['X-Accel-Redirect']).to eq cdr.call_record_filename
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
      let(:record_id) { SecureRandom.uuid }

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
