# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CdrsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:cdrs) do
      create_list :cdr, 12, :with_id, time_start: 2.days.ago.utc
    end
    subject { get :index, params: { filter: filters, page: { number: page_number, size: 10 }, sort: 'id' } }
    let(:filters) do
      {}
    end
    let(:page_number) do
      1
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response should contain valid count of items respects pagination' do
      subject
      expect(response_data.size).to eq(10)
    end

    it 'total-count should be present in meta info' do
      subject
      expect(JSON.parse(response.body)['meta']).to eq(
        'total-count' => cdrs.size
      )
    end

    context 'get second page' do
      let(:page_number) do
        2
      end

      it 'response should contain valid count of items respects pagination' do
        subject
        expect(response_data.size).to eq(2)
        expect(response_data.map { |cdr| cdr['id'].to_i }).to match_array(cdrs[-2..-1].map(&:id))
      end
    end

    context 'filtering' do
      context 'by customer_auth_external_id_eq' do
        let(:filters) do
          { 'customer-auth-external-id-eq' => customer_auth.external_id }
        end
        let(:customer_auth) do
          create(:customers_auth, external_id: 123)
        end
        let!(:cdr) do
          create :cdr, :with_id, customer_auth_external_id: customer_auth.external_id
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by customer_acc_external_id_eq' do
        let(:filters) do
          { 'customer-acc-external-id-eq' => cdr.customer_acc_external_id }
        end
        let!(:cdr) do
          create :cdr, :with_id, customer_acc_external_id: 123_123
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by failed_resource_type_id_eq' do
        let(:filters) do
          { 'failed-resource-type-id-eq' => cdr.failed_resource_type_id }
        end
        let!(:cdr) do
          create :cdr, :with_id, failed_resource_type_id: 3
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by success_eq' do
        let(:filters) do
          { 'success-eq' => true }
        end
        before do
          Cdr::Cdr.where(id: cdrs.map(&:id)).update_all(success: false)
        end
        let!(:cdr) do
          create :cdr, :with_id, success: true
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by is_last_cdr_eq' do
        let(:filters) do
          { 'is-last-cdr-eq' => true }
        end
        before do
          Cdr::Cdr.where(id: cdrs.map(&:id)).update_all(is_last_cdr: false)
        end
        let!(:cdr) do
          create :cdr, :with_id, is_last_cdr: true
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by src_prefix_in_contains' do
        let(:filters) do
          { 'src-prefix-in-contains' => '12345' }
        end
        let!(:cdr) do
          create :cdr, :with_id, src_prefix_in: '0123456789'
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by dst_prefix_in_contains' do
        let(:filters) do
          { 'dst-prefix-in-contains' => '12345' }
        end
        let!(:cdr) do
          create :cdr, :with_id, dst_prefix_in: '0123456789'
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by src_prefix_routing_contains' do
        let(:filters) do
          { 'src-prefix-routing-contains' => '12345' }
        end
        let!(:cdr) do
          create :cdr, :with_id, src_prefix_routing: '0123456789'
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by dst_prefix_routing_contains' do
        let(:filters) do
          { 'dst-prefix-routing-contains' => '12345' }
        end
        let!(:cdr) do
          create :cdr, :with_id, dst_prefix_routing: '0123456789'
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by time_start_gteq' do
        let(:filters) do
          { 'time-start-gteq' => Time.now.utc.beginning_of_day }
        end
        let!(:cdr) do
          create :cdr, :with_id, time_start: Time.now.utc
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by time_start_lteq' do
        let(:filters) do
          { 'time-start-lteq' => 15.days.ago.utc }
        end
        let!(:cdr) do
          create :cdr, :with_id, time_start: 20.days.ago.utc
        end
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(
            hash_including(
              'id' => cdr.id.to_s
            )
          )
        end
      end

      context 'by dst_country_id_eq' do
        let(:filters) do
          { 'dst-country-id-eq' => country.id }
        end
        let!(:cdr) do
          create :cdr, :with_id, dst_country_id: country.id
        end
        let(:country) { System::Country.take! }
        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(hash_including('id' => cdr.id.to_s))
        end
      end

      context 'by src_country_id_eq' do
        let(:filters) do
          { 'src-country-id-eq' => country.id }
        end
        let!(:cdr) do
          create :cdr, :with_id, src_country_id: country.id
        end
        let(:country) { System::Country.take! }

        it 'only desired cdrs should be present' do
          subject
          expect(response_data).to match_array(hash_including('id' => cdr.id.to_s))
        end
      end

      context 'by dst_country_iso_eq' do
        context 'when valid iso2 country code' do
          let(:filters) do
            { 'dst-country-iso-eq' => country.iso2 }
          end
          let!(:cdr) do
            create :cdr, :with_id, dst_country_id: country.id
          end
          let(:country) { System::Country.take! }
          it 'only desired cdrs should be present' do
            subject
            expect(response_data).to match_array(hash_including('id' => cdr.id.to_s))
          end
        end

        context 'when invalid iso2 country code' do
          let(:filters) do
            { 'dst-country-iso-eq' => 'invalid iso code' }
          end

          it 'should be raise InvalidFilterValue and return 400' do
            subject
            expect(response_body[:errors].first).to include(
                                                      {
                                                        title: 'Invalid filter value',
                                                        detail: 'invalid iso code is not a valid value for dst_country_iso_eq.',
                                                        status: '400'
                                                      }
                                                    )

            expect(response).to have_http_status(:bad_request)
          end
        end
      end

      context 'by src_country_iso_eq' do
        context 'when invalid iso2 country code' do
          let(:filters) do
            { 'src-country-iso-eq' => 'invalid iso code' }
          end

          it 'should be raise InvalidFilterValue and return 400' do
            subject
            expect(response_body[:errors].first).to include(
                                            {
                                              title: 'Invalid filter value',
                                              detail: 'invalid iso code is not a valid value for scr_country_iso_eq.',
                                              status: '400'
                                            }
                                          )

            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'when valid iso2 country code' do
          let(:filters) do
            { 'src-country-iso-eq' => country.iso2 }
          end
          let!(:cdr) do
            create :cdr, :with_id, src_country_id: country.id
          end
          let(:country) { System::Country.take! }
          it 'only desired cdrs should be present' do
            subject
            expect(response_data).to match_array(hash_including('id' => cdr.id.to_s))
          end
        end
      end

      context 'by routing_tag_ids_include' do
        let(:filters) { { 'routing-tag-ids-include' => routing_tag_ids.first } }
        let!(:cdr) { create :cdr, :with_id, routing_tag_ids: routing_tag_ids }
        let!(:another_cdr) { create(:cdr, routing_tag_ids: [another_routing_id]) }
        let(:routing_tag_ids) { create_list(:routing_tag, 5).map(&:id) }
        let(:another_routing_id) { create(:routing_tag).id }

        it 'only desired cdrs should be present' do
          subject
          expect(response_data.size).to eq(1)
          expect(response_data).to match_array(hash_including('id' => cdr.id.to_s))
        end
      end

      context 'by routing_tag_ids_exclude' do
        let(:filters) { { 'routing-tag-ids-exclude' => another_routing_id } }
        let!(:cdr) { create :cdr, :with_id, routing_tag_ids: routing_tag_ids }
        let(:routing_tag_ids) { create_list(:routing_tag, 5).map(&:id) }
        let(:another_routing_id) { create(:routing_tag).id }

        it 'only desired cdrs should be present' do
          subject
          expect(response_data.size).to eq(1)
          expect(response_data).to match_array(hash_including('id' => cdr.id.to_s))
        end
      end

      context 'by routing_tag_ids_empty' do
        let!(:cdrs) {}
        let!(:cdr) { create :cdr, :with_id, routing_tag_ids: {} }
        let!(:another_cdr) { create(:cdr, routing_tag_ids: [another_routing_id]) }
        let(:another_routing_id) { create(:routing_tag).id }

        context 'with true value' do
          let(:filters) { { 'routing-tag-ids-empty' => true } }

          it 'only desired cdrs should be present' do
            subject
            expect(response_data.size).to eq(1)
            expect(response_data).to match_array(hash_including('id' => cdr.id.to_s))
          end
        end

        context 'with false value' do
          let(:filters) { { 'routing-tag-ids-empty' => false } }

          it 'only desired cdrs should be present' do
            subject
            expect(response_data.size).to eq(1)
            expect(response_data).to match_array(hash_including('id' => another_cdr.id.to_s))
          end
        end
      end

      context 'by customer_auth_external_type_eq' do
        let(:filters) { { 'customer-auth-external-type-eq' => customer_auth.external_type } }
        let(:customer_auth) { FactoryBot.create(:customers_auth, external_id: 123, external_type: 'term') }
        let!(:cdr) { FactoryBot.create(:cdr, :with_id, customer_auth_external_id: customer_auth.external_id, customer_auth_external_type: customer_auth.external_type) }

        it 'only desired cdrs should be present' do
          subject
          expect(response_data.size).to eq(1)
          expect(response_data).to match_array([hash_including('id' => cdr.id.to_s)])
        end
      end

      context 'by customer_auth_external_type_not_eq' do
        let(:filters) { { 'customer-auth-external-type-not-eq' => customer_auth_1.external_type } }
        let(:customer_auth_1) { FactoryBot.create(:customers_auth, external_id: 111, external_type: 'em') }
        let(:customer_auth_2) { FactoryBot.create(:customers_auth, external_id: 222, external_type: 'term') }
        let(:customer_auth_3) { FactoryBot.create(:customers_auth, external_id: 333, external_type: nil) }
        let(:cdrs) { nil }
        let!(:cdr_1) { FactoryBot.create(:cdr, :with_id, customer_auth_external_id: customer_auth_1.external_id, customer_auth_external_type: customer_auth_1.external_type) }
        let!(:cdr_2) { FactoryBot.create(:cdr, :with_id, customer_auth_external_id: customer_auth_2.external_id, customer_auth_external_type: customer_auth_2.external_type) }
        let!(:cdr_3) { FactoryBot.create(:cdr, :with_id, customer_auth_external_id: customer_auth_3.external_id, customer_auth_external_type: customer_auth_3.external_type) }

        it 'only desired cdrs should be present' do
          subject
          expect(response_data.size).to eq(2)
          expect(response_data).to match_array(
            [
              hash_including('id' => cdr_2.id.to_s),
              hash_including('id' => cdr_3.id.to_s)
            ]
          )
        end
      end
    end

    it_behaves_like :save_api_logs do
      let(:message) { '200 GET /api/rest/admin/cdrs Api::Rest::Admin::CdrsController 0.0.0.0' }
      let(:controller) { 'Api::Rest::Admin::CdrsController' }
      let(:action) { 'index' }
      let(:path) { '/api/rest/admin/cdrs' }
      let(:method) { 'GET' }
      let(:status) { 200 }
    end
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :cdr }
    let(:trait) { :with_id_and_uuid }
    let(:json_api_request_query) { nil }

    # TODO add tests for filters by foreign keys

    it_behaves_like :jsonapi_filters_by_datetime_field, :time_start
    it_behaves_like :jsonapi_filters_by_number_field, :destination_next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :destination_fee
    it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_next_rate
    it_behaves_like :jsonapi_filters_by_number_field, :dialpeer_fee
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
    it_behaves_like :jsonapi_filters_by_boolean_field, :is_last_cdr
    it_behaves_like :jsonapi_filters_by_number_field, :lega_disconnect_code
    it_behaves_like :jsonapi_filters_by_string_field, :lega_disconnect_reason
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
    it_behaves_like :jsonapi_filters_by_string_field, :p_charge_info_in
  end

  describe 'GET show' do
    let!(:cdr) do
      create :cdr, :with_id
    end

    subject { get :show, params: { id:, include: includes.join(',') } }

    let(:id) { cdr.id }
    let(:includes) do
      %w[rateplan dialpeer pop routing-group destination customer-auth vendor customer vendor-acc customer-acc orig-gw term-gw routing-plan src-country src-network src-network-type dst-country dst-network dst-network-type]
    end

    it 'http status should eq 200' do
      subject
      expect(response.status).to eq(200)
    end

    it 'response body should be valid' do
      subject
      expect(response_data).to match(
        hash_including(
          'id' => cdr.id.to_s,
          'type' => 'cdrs',
          'attributes' => {
            'time-start' => cdr.time_start.iso8601(3),
            'destination-next-rate' => cdr.destination_next_rate.to_s,
            'destination-fee' => cdr.destination_fee.to_s,
            'dialpeer-next-rate' => cdr.dialpeer_next_rate,
            'dialpeer-fee' => cdr.dialpeer_fee,
            'internal-disconnect-code' => cdr.internal_disconnect_code,
            'internal-disconnect-reason' => cdr.internal_disconnect_reason,
            'disconnect-initiator-id' => cdr.disconnect_initiator_id,
            'customer-price' => cdr.customer_price.to_s,
            'vendor-price' => cdr.vendor_price,
            'duration' => cdr.duration,
            'success' => cdr.success,
            'profit' => cdr.profit,
            'dst-prefix-in' => cdr.dst_prefix_in,
            'dst-prefix-out' => cdr.dst_prefix_out,
            'src-prefix-in' => cdr.src_prefix_in,
            'src-prefix-out' => cdr.src_prefix_out,
            'time-connect' => cdr.time_connect.iso8601(3),
            'time-end' => cdr.time_end.iso8601(3),
            'sign-orig-ip' => cdr.sign_orig_ip,
            'sign-orig-port' => cdr.sign_orig_port,
            'sign-orig-local-ip' => cdr.sign_orig_local_ip,
            'sign-orig-local-port' => cdr.sign_orig_local_port,
            'sign-term-ip' => cdr.sign_term_ip,
            'sign-term-port' => cdr.sign_term_port,
            'sign-term-local-ip' => cdr.sign_term_local_ip,
            'sign-term-local-port' => cdr.sign_term_local_port,
            'orig-call-id' => cdr.orig_call_id,
            'term-call-id' => cdr.term_call_id,
            'vendor-invoice-id' => cdr.vendor_invoice_id,
            'customer-invoice-id' => cdr.customer_invoice_id,
            'local-tag' => cdr.local_tag,
            'destination-initial-rate' => cdr.destination_initial_rate.to_s,
            'dialpeer-initial-rate' => cdr.dialpeer_initial_rate,
            'destination-initial-interval' => cdr.destination_initial_interval,
            'destination-next-interval' => cdr.destination_next_interval,
            'dialpeer-initial-interval' => cdr.dialpeer_initial_interval,
            'dialpeer-next-interval' => cdr.dialpeer_next_interval,
            'routing-attempt' => cdr.routing_attempt,
            'is-last-cdr' => cdr.is_last_cdr,
            'lega-disconnect-code' => cdr.lega_disconnect_code,
            'lega-disconnect-reason' => cdr.lega_disconnect_reason,
            'src-name-in' => cdr.src_name_in,
            'src-name-out' => cdr.src_name_out,
            'diversion-in' => cdr.diversion_in,
            'diversion-out' => cdr.diversion_out,
            'legb-disconnect-code' => cdr.legb_disconnect_code,
            'legb-disconnect-reason' => cdr.legb_disconnect_reason,
            'dump-level-id' => cdr.dump_level_id,
            'auth-orig-ip' => cdr.auth_orig_ip,
            'auth-orig-port' => cdr.auth_orig_port,
            'global-tag' => cdr.global_tag,
            'src-prefix-routing' => cdr.src_prefix_routing,
            'dst-prefix-routing' => cdr.dst_prefix_routing,
            'routing-delay' => cdr.routing_delay,
            'pdd' => cdr.pdd,
            'rtt' => cdr.rtt,
            'early-media-present' => cdr.early_media_present,
            'lnp-database-id' => cdr.lnp_database_id,
            'lrn' => cdr.lrn,
            'destination-prefix' => cdr.destination_prefix,
            'dialpeer-prefix' => cdr.dialpeer_prefix,
            'audio-recorded' => cdr.audio_recorded,
            'ruri-domain' => cdr.ruri_domain,
            'to-domain' => cdr.to_domain,
            'from-domain' => cdr.from_domain,
            'src-area-id' => cdr.src_area_id,
            'dst-area-id' => cdr.dst_area_id,
            'auth-orig-transport-protocol-id' => cdr.auth_orig_transport_protocol_id,
            'sign-orig-transport-protocol-id' => cdr.sign_orig_transport_protocol_id,
            'sign-term-transport-protocol-id' => cdr.sign_term_transport_protocol_id,
            'core-version' => cdr.core_version,
            'yeti-version' => cdr.yeti_version,
            'lega-user-agent' => cdr.lega_user_agent,
            'legb-user-agent' => cdr.legb_user_agent,
            'uuid' => cdr.uuid,
            'pai-in' => cdr.pai_in,
            'ppi-in' => cdr.ppi_in,
            'privacy-in' => cdr.privacy_in,
            'rpid-in' => cdr.rpid_in,
            'rpid-privacy-in' => cdr.rpid_privacy_in,
            'pai-out' => cdr.pai_out,
            'ppi-out' => cdr.ppi_out,
            'privacy-out' => cdr.privacy_out,
            'rpid-out' => cdr.rpid_out,
            'rpid-privacy-out' => cdr.rpid_privacy_out,
            'destination-reverse-billing' => cdr.destination_reverse_billing,
            'dialpeer-reverse-billing' => cdr.dialpeer_reverse_billing,
            'is-redirected' => cdr.is_redirected,
            'customer-account-check-balance' => cdr.customer_account_check_balance,
            'customer-external-id' => cdr.customer_external_id,
            'customer-auth-external-id' => cdr.customer_auth_external_id,
            'customer-acc-vat' => cdr.customer_acc_vat,
            'customer-acc-external-id' => cdr.customer_acc_external_id,
            'routing-tag-ids' => cdr.routing_tag_ids,
            'vendor-external-id' => cdr.vendor_external_id,
            'vendor-acc-external-id' => cdr.vendor_acc_external_id,
            'orig-gw-external-id' => cdr.orig_gw_external_id,
            'term-gw-external-id' => cdr.term_gw_external_id,
            'failed-resource-type-id' => cdr.failed_resource_type_id,
            'failed-resource-id' => cdr.failed_resource_id,
            'customer-price-no-vat' => cdr.customer_price_no_vat,
            'customer-duration' => cdr.customer_duration,
            'vendor-duration' => cdr.vendor_duration,
            'destination-rate-policy-id' => cdr.destination_rate_policy_id,
            'metadata' => nil,
            'p-charge-info-in' => cdr.p_charge_info_in
          },
          'relationships' => hash_including(
            'rateplan' => hash_including(
              'data' => nil
            ),
            'dialpeer' => hash_including(
              'data' => nil
            ),
            'pop' => hash_including(
              'data' => nil
            ),
            'node' => hash_including(
              'data' => nil
            ),
            'routing-group' => hash_including(
              'data' => nil
            ),
            'routing-plan' => hash_including(
              'data' => nil
            ),
            'destination' => hash_including(
              'data' => nil
            ),
            'customer-auth' => hash_including(
              'data' => nil
            ),
            'vendor' => hash_including(
              'data' => {
                'type' => 'contractors',
                'id' => cdr.vendor_id.to_s
              }
            ),
            'customer' => hash_including(
              'data' => {
                'type' => 'contractors',
                'id' => cdr.customer_id.to_s
              }
            ),
            'customer-acc' => hash_including(
              'data' => {
                'type' => 'accounts',
                'id' => cdr.customer_acc_id.to_s
              }
            ),
            'vendor-acc' => hash_including(
              'data' => {
                'type' => 'accounts',
                'id' => cdr.vendor_acc_id.to_s
              }
            ),
            'orig-gw' => hash_including(
              'data' => nil
            ),
            'term-gw' => hash_including(
              'data' => nil
            ),
            'src-country' => hash_including(
              'data' => nil
            ),
            'src-network' => hash_including(
              'data' => nil
            ),
            'src-network-type' => hash_including(
              'data' => nil
            ),
            'dst-country' => hash_including(
              'data' => nil
            ),
            'dst-network' => hash_including(
              'data' => nil
            ),
            'dst-network-type' => hash_including(
              'data' => nil
            )
          )
        )
      )
    end

    it_behaves_like :save_api_logs do
      let(:message) { "200 GET /api/rest/admin/cdrs/#{id} Api::Rest::Admin::CdrsController 0.0.0.0" }
      let(:controller) { 'Api::Rest::Admin::CdrsController' }
      let(:action) { 'show' }
      let(:path) { "/api/rest/admin/cdrs/#{id}" }
      let(:method) { 'GET' }
      let(:status) { 200 }
    end

    context 'when record does not exist' do
      let(:id) { 9_999_999 }

      it 'response body should be valid' do
        subject

        expect(response.status).to eq(404)
      end

      it_behaves_like :save_api_logs do
        let(:message) { "404 GET /api/rest/admin/cdrs/#{id} Api::Rest::Admin::CdrsController 0.0.0.0" }
        let(:controller) { 'Api::Rest::Admin::CdrsController' }
        let(:action) { 'show' }
        let(:path) { "/api/rest/admin/cdrs/#{id}" }
        let(:method) { 'GET' }
        let(:status) { 404 }
      end
    end
  end

  describe 'POST create' do
    it 'POST should not be routable', type: :routing do
      expect(post: '/api/rest/admin/cdrs').to_not be_routable
    end
  end

  describe 'PATCH update' do
    it 'PATCH should be routable', type: :routing do
      expect(patch: '/api/rest/admin/cdrs/123').to be_routable
    end
  end

  describe 'DELETE destroy' do
    it 'DELETE should not be routable', type: :routing do
      expect(delete: '/api/rest/admin/cdrs/123').to_not be_routable
    end
  end
end
