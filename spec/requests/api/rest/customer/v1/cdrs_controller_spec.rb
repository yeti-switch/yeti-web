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

    context 'with default filters (time_start_gteq)' do
      let!(:cdrs) do
        [
          create(:cdr, customer_acc: account),
          create(:cdr, customer_acc: account, time_start: 23.hours.ago)
        ]
      end

      before do
        # ignored because default filter is time_start_gteq: 24.hours.ago
        create(:cdr, customer_acc: account, time_start: 25.hours.ago)
        create(:cdr, customer_acc: account, time_start: 35.hours.ago)

        # ignored because base collection has only records with is_last_cdr=true
        create(:cdr, customer_acc: account, is_last_cdr: false)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].pluck(:id)
        expect(actual_ids).to match_array(cdrs.map { |c| c.id.to_s })
      end
    end

    context 'with time_start_gteq filter' do
      let(:json_api_request_query) do
        { filter: { time_start_gteq: 48.hours.ago.strftime('%F %T') } }
      end
      let!(:cdrs) do
        [
          create(:cdr, customer_acc: account),
          create(:cdr, customer_acc: account, time_start: 23.hours.ago),
          # included in collection because passed filter time_start_gteq overrides default filter time_start_gteq
          create(:cdr, customer_acc: account, time_start: 47.hours.ago)
        ]
      end

      before do
        # ignored because passed filter is time_start_gteq: 48.hours.ago
        create(:cdr, customer_acc: account, time_start: 49.hours.ago)
        create(:cdr, customer_acc: account, time_start: 100.days.ago)

        # ignored because base collection has only records with is_last_cdr=true
        create(:cdr, customer_acc: account, is_last_cdr: false)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].pluck(:id)
        expect(actual_ids).to match_array(cdrs.map { |c| c.id.to_s })
      end
    end

    context 'with time_start_gt filter' do
      let(:json_api_request_query) do
        { filter: { time_start_gt: 48.hours.ago.strftime('%F %T') } }
      end
      let!(:cdrs) do
        [
          create(:cdr, customer_acc: account),
          create(:cdr, customer_acc: account, time_start: 23.hours.ago),
          # included in collection because default filter time_start_gteq skipped when filter time_start_gt passed
          create(:cdr, customer_acc: account, time_start: 47.hours.ago)
        ]
      end

      before do
        # ignored because passed filter is time_start_gteq: 48.hours.ago
        create(:cdr, customer_acc: account, time_start: 49.hours.ago)
        create(:cdr, customer_acc: account, time_start: 100.days.ago)

        # ignored because base collection has only records with is_last_cdr=true
        create(:cdr, customer_acc: account, is_last_cdr: false)
      end

      it 'returns records of this customer' do
        subject
        expect(response.status).to eq(200)
        actual_ids = response_json[:data].pluck(:id)
        expect(actual_ids).to match_array(cdrs.map { |c| c.id.to_s })
      end
    end

    context 'account_ids is empty' do
      let(:cdrs) { Cdr::Cdr.where(customer_id: customer.id, is_last_cdr: true) }
      let(:records_qty) { 2 }

      before { create_list(:cdr, records_qty, customer_acc: account) }

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
            hash_including(id: cdrs[0].id.to_s),
            hash_including(id: cdrs[1].id.to_s)
          ]
        )
      end
    end

    context 'with filters by account' do
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
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end

      context 'account_id_not_eq' do
        let(:request_filters) { { account_id_not_eq: account.reload.uuid } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, customer_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end

      context 'account_id_in' do
        let(:request_filters) { { account_id_in: "#{another_account.reload.uuid},#{another_account2.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:another_account2) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, customer_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end

      context 'account_id_not_in' do
        let(:request_filters) { { account_id_not_in: "#{account.reload.uuid},#{another_account2.reload.uuid}" } }
        let!(:another_account) { create(:account, contractor: customer) }
        let!(:another_account2) { create(:account, contractor: customer) }
        let!(:expected_record) { create(:cdr, customer_acc: another_account) }

        it 'response contains only one filtered record' do
          subject
          expect(response_json[:data]).to match_array([hash_including(id: expected_record.id.to_s)])
        end
      end
    end

    context 'with ransack filters' do
      let(:factory) { :cdr }
      let(:trait) { :with_id_and_uuid }
      let(:factory_attrs) { { customer: customer } }
      let(:pk) { :id }

      it_behaves_like :jsonapi_filters_by_number_field, :id
      it_behaves_like :jsonapi_filters_by_datetime_field, :time_start do
        # overrides default filter to avoid conflicts with tests
        let(:json_api_request_query) do
          { filter: { time_start_gteq: 50.days.ago.strftime('%F %T') } }
        end
      end
      it_behaves_like :jsonapi_filters_by_datetime_field, :time_connect
      it_behaves_like :jsonapi_filters_by_datetime_field, :time_end
      it_behaves_like :jsonapi_filters_by_number_field, :duration
      it_behaves_like :jsonapi_filters_by_boolean_field, :success

      it_behaves_like :jsonapi_filters_by_number_field, :lega_disconnect_code
      it_behaves_like :jsonapi_filters_by_string_field, :lega_disconnect_reason

      it_behaves_like :jsonapi_filters_by_string_field, :dst_prefix_in
      it_behaves_like :jsonapi_filters_by_string_field, :src_prefix_in
      it_behaves_like :jsonapi_filters_by_string_field, :src_name_in
      it_behaves_like :jsonapi_filters_by_string_field, :src_prefix_routing
      it_behaves_like :jsonapi_filters_by_string_field, :dst_prefix_routing
      it_behaves_like :jsonapi_filters_by_string_field, :diversion_in

      it_behaves_like :jsonapi_filters_by_number_field, :auth_orig_transport_protocol_id
      it_behaves_like :jsonapi_filters_by_inet_field, :auth_orig_ip
      it_behaves_like :jsonapi_filters_by_number_field, :auth_orig_port
      it_behaves_like :jsonapi_filters_by_string_field, :orig_call_id

      it_behaves_like :jsonapi_filters_by_string_field, :local_tag
      it_behaves_like :jsonapi_filters_by_string_field, :destination_prefix
      it_behaves_like :jsonapi_filters_by_number_field, :destination_initial_rate
      it_behaves_like :jsonapi_filters_by_number_field, :destination_next_rate
      it_behaves_like :jsonapi_filters_by_number_field, :destination_fee
      it_behaves_like :jsonapi_filters_by_number_field, :destination_initial_interval
      it_behaves_like :jsonapi_filters_by_number_field, :destination_next_interval
      it_behaves_like :jsonapi_filters_by_boolean_field, :destination_reverse_billing
      it_behaves_like :jsonapi_filters_by_number_field, :customer_acc_vat
      it_behaves_like :jsonapi_filters_by_number_field, :customer_price
      it_behaves_like :jsonapi_filters_by_number_field, :customer_price_no_vat
      it_behaves_like :jsonapi_filters_by_number_field, :customer_duration

      it_behaves_like :jsonapi_filters_by_string_field, :ruri_domain
      it_behaves_like :jsonapi_filters_by_string_field, :to_domain
      it_behaves_like :jsonapi_filters_by_string_field, :from_domain

      it_behaves_like :jsonapi_filters_by_string_field, :pai_in
      it_behaves_like :jsonapi_filters_by_string_field, :ppi_in
      it_behaves_like :jsonapi_filters_by_string_field, :privacy_in
      it_behaves_like :jsonapi_filters_by_string_field, :rpid_in
      it_behaves_like :jsonapi_filters_by_string_field, :rpid_privacy_in
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
          data = response_json[:data].detect { |item| item[:id] == cdr.id.to_s }
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
        expect(actual_ids).to match_array cdrs.map { |c| c.id.to_s }
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
          data = response_json[:data].detect { |item| item[:id] == cdr.id.to_s }
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
        expect(actual_ids).to match_array cdrs.map { |c| c.id.to_s }
      end
    end
  end

  describe 'GET /api/rest/customer/v1/cdrs/{id}' do
    subject do
      get json_api_request_path, params: json_api_request_query, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { cdr.id.to_s }
    let(:json_api_request_query) { nil }

    let!(:cdr) { create(:cdr, :with_id, cdr_attrs).reload }
    let(:cdr_attrs) { { customer_acc: account } }

    it_behaves_like :json_api_customer_v1_check_authorization

    it 'returns record with expected attributes' do
      subject
      expect(response_json[:data]).to match(
        id: cdr.id.to_s,
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
          'customer-duration': cdr.customer_duration,
          'src-name-in': cdr.src_name_in,
          'src-prefix-in': cdr.src_prefix_in,
          'from-domain': cdr.from_domain,
          'dst-prefix-in': cdr.dst_prefix_in,
          'to-domain': cdr.to_domain,
          'ruri-domain': cdr.ruri_domain,
          'diversion-in': cdr.diversion_in,
          'local-tag': cdr.local_tag,
          'orig-call-id': cdr.orig_call_id,
          'lega-disconnect-code': cdr.lega_disconnect_code,
          'lega-disconnect-reason': cdr.lega_disconnect_reason,
          'auth-orig-transport-protocol-id': cdr.auth_orig_transport_protocol_id,
          'auth-orig-ip': cdr.auth_orig_ip,
          'auth-orig-port': cdr.auth_orig_port,
          'src-prefix-routing': cdr.src_prefix_routing,
          'dst-prefix-routing': cdr.dst_prefix_routing,
          'destination-prefix': cdr.destination_prefix,
          'lega-user-agent': cdr.lega_user_agent,
          rec: false
        }
      )
    end

    context 'when api.customer.outgoing_cdr_hide_fields configured' do
      before do
        allow(YetiConfig.api.customer).to receive(:outgoing_cdr_hide_fields).and_return(
          %w[auth_orig_ip lega_user_agent]
        )
      end

      it 'returns record with expected attributes' do
        subject
        attribute_keys = response_json[:data][:attributes].keys
        expect(attribute_keys).to include(:'auth-orig-port')
        expect(attribute_keys).not_to include(:'auth-orig-ip')
        expect(attribute_keys).not_to include(:'lega-user-agent')
      end
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

    context 'when customer_portal_access_profile.allow_listen_recording=true' do
      before { api_access.customer_portal_access_profile.update!(allow_listen_recording: true) }

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

    context 'when customer_portal_access_profile.allow_listen_recording=false' do
      before { api_access.customer_portal_access_profile.update!(allow_listen_recording: false) }

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

    before { api_access.customer_portal_access_profile.update!(allow_listen_recording:) }

    let(:allow_listen_recording) { true }
    let(:json_api_request_path) { "#{super()}/#{record_id}/rec" }
    let(:record_id) { cdr.id.to_s }
    let!(:cdr) { create(:cdr, :with_id, cdr_attrs).reload }
    let(:cdr_attrs) do
      { customer_acc: account, audio_recorded: true, local_tag: SecureRandom.uuid, duration: 12 }
    end

    it 'responds with X-Accel-Redirect' do
      expect(Cdr::DownloadCallRecord).to receive(:call).with(cdr:, response_object: be_present).and_call_original

      subject
      expect(response.status).to eq 200
      expect(response.body).to be_blank
      expect(response.headers['X-Accel-Redirect']).to eq cdr.call_record_file_path
      expect(response.headers['Content-Type']).to eq cdr.call_record_ct
    end

    context 'when s3 storage configured' do
      before do
        allow(YetiConfig).to receive(:s3_storage).and_return(
          OpenStruct.new(
            endpoint: 'http::some_example_s3_storage_url',
            pcap: OpenStruct.new(bucket: 'test-pcap-bucket'),
            call_record: OpenStruct.new(bucket: 'test-call-record-bucket')
          )
        )

        allow(S3AttachmentWrapper).to receive(:stream_to!).and_yield("dummy data\n").and_yield('dummy data2')
      end

      it 'responds with attachment' do
        expect(Cdr::DownloadCallRecord).to receive(:call).with(cdr:, response_object: be_present).and_call_original

        subject
        expect(response.status).to eq(200)
        expect(response.body).to eq("dummy data\ndummy data2")
        expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{cdr.call_record_file_name}\"")
        expect(response.headers['Content-Type']).to eq('application/octet-stream')
      end
    end

    context 'when Cdr::DownloadCallRecord raise Cdr::DownloadCallRecord::NotFoundError' do
      before do
        allow(Cdr::DownloadCallRecord).to receive(:call).and_raise(Cdr::DownloadCallRecord::NotFoundError, 'Test error')
      end

      include_examples :responds_404
    end

    context 'when Cdr::DownloadCallRecord raise Cdr::DownloadCallRecord::Error' do
      before do
        allow(Cdr::DownloadCallRecord).to receive(:call).and_raise(Cdr::DownloadCallRecord::Error, 'Test error')
      end

      include_examples :jsonapi_server_error
    end

    context 'when Cdr::DownloadCallRecord raise any other error' do
      before do
        allow(Cdr::DownloadCallRecord).to receive(:call).and_raise(StandardError, 'Test error')
      end

      include_examples :jsonapi_server_error
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

    context 'when customer_portal_access_profile.allow_listen_recording=false' do
      let(:allow_listen_recording) { false }

      include_examples :responds_404
    end

    context 'with invalid ID' do
      let(:record_id) { -3000 }

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
