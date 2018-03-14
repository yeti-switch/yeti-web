require 'spec_helper'

describe Api::Rest::Admin::Cdr::CdrsController, type: :controller do

  let(:admin_user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: admin_user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end
  after { Cdr::Cdr.destroy_all }

  describe 'GET index' do
    let!(:cdrs) do
      create_list :cdr, 12, :with_id, time_start: 1.month.ago.utc
    end
    subject { get :index, filter: filters, page: { number: page_number, size: 10 } }
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
        {
          'total-count' => cdrs.size
        }
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
          create(:customers_auth, ip: '127.0.0.1/32', external_id: 123)
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
          create :cdr, :with_id, customer_acc_external_id: 123123
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

      context 'by time_start_greater_or_eq' do
        let(:filters) do
          { 'time-start-greater-or-eq' => Time.now.utc.beginning_of_month }
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

      context 'by time_start_less_or_eq' do
        let(:filters) do
          { 'time-start-less-or-eq' => 45.days.ago.utc }
        end
        let!(:cdr) do
          create :cdr, :with_id, time_start: 2.months.ago.utc
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
    end
  end

  describe 'GET show' do
    let!(:cdr) do
      create :cdr, :with_id
    end

    subject do
      get :show, id: cdr.id, include: includes.join(',')
    end
    let(:includes) do
      %w(rateplan dialpeer pop routing-group destination customer-auth vendor customer vendor-acc customer-acc orig-gw term-gw destination-rate-policy routing-plan country network)
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
            'time-limit' => cdr.time_limit,
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
            'node-id' => cdr.node_id,
            'src-name-in' => cdr.src_name_in,
            'src-name-out' => cdr.src_name_out,
            'diversion-in' => cdr.diversion_in,
            'diversion-out' => cdr.diversion_out,
            'lega-rx-payloads' => cdr.lega_rx_payloads,
            'lega-tx-payloads' => cdr.lega_tx_payloads,
            'legb-rx-payloads' => cdr.legb_rx_payloads,
            'legb-tx-payloads' => cdr.legb_tx_payloads,
            'legb-disconnect-code' => cdr.legb_disconnect_code,
            'legb-disconnect-reason' => cdr.legb_disconnect_reason,
            'dump-level-id' => cdr.dump_level_id,
            'auth-orig-ip' => cdr.auth_orig_ip,
            'auth-orig-port' => cdr.auth_orig_port,
            'lega-rx-bytes' => cdr.lega_rx_bytes,
            'lega-tx-bytes' => cdr.lega_tx_bytes,
            'legb-rx-bytes' => cdr.legb_rx_bytes,
            'legb-tx-bytes' => cdr.legb_tx_bytes,
            'global-tag' => cdr.global_tag,
            'dst-country-id' => cdr.dst_country_id,
            'dst-network-id' => cdr.dst_network_id,
            'lega-rx-decode-errs' => cdr.lega_rx_decode_errs,
            'lega-rx-no-buf-errs' => cdr.lega_rx_no_buf_errs,
            'lega-rx-parse-errs' => cdr.lega_rx_parse_errs,
            'legb-rx-decode-errs' => cdr.legb_rx_decode_errs,
            'legb-rx-no-buf-errs' => cdr.legb_rx_no_buf_errs,
            'legb-rx-parse-errs' => cdr.legb_rx_parse_errs,
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
            'vendor-duration' => cdr.vendor_duration
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
            'destination-rate-policy' => hash_including(
              'data' => nil
            ),
            'vendor' => hash_including(
              'data' => nil
            ),
            'customer' => hash_including(
              'data' => {
                'type' => 'contractors',
                'id' => cdr.customer.id.to_s
              }
            ),
            'customer-acc' => hash_including(
              'data' => {
                'type' => 'accounts',
                'id' => cdr.customer_acc.id.to_s
              }
            ),
            'vendor-acc' => hash_including(
              'data' => nil
            ),
            'orig-gw' => hash_including(
              'data' => nil
            ),
            'term-gw' => hash_including(
              'data' => nil
            ),
            'country' => hash_including(
              'data' => nil
            ),
            'network' => hash_including(
              'data' => nil
            )
          ),
        )
      )
    end
  end

  describe 'POST create' do
    it 'POST should not be routable', type: :routing do
      expect(post: '/api/rest/admin/cdr/cdrs').to_not be_routable
    end
  end

  describe 'PATCH create' do
    it 'PATCH should not be routable', type: :routing do
      expect(patch: '/api/rest/admin/cdr/cdrs/123').to_not be_routable
    end
  end

  describe 'DELETE create' do
    it 'DELETE should not be routable', type: :routing do
      expect(delete: '/api/rest/admin/cdr/cdrs/123').to_not be_routable
    end
  end
end
