# frozen_string_literal: true

RSpec.describe Api::Rest::System::IpAccessController, type: :controller do
  describe '#index' do
    subject { get :index, params: { format: :json } }

    let(:body) { JSON.parse(response.body) }

    before do
      # Default: pretend ClickHouse is not configured so CDR branch is skipped
      # unless a context overrides this.
      allow(ClickHouse).to receive(:config).and_return(double(url: nil))
    end

    context 'with no records' do
      it 'returns empty arrays under both keys' do
        subject
        expect(body).to eq('lega_sip_ips' => [], 'lega_rtp_ips' => [])
      end
    end

    context 'with CustomersAuth records and no mask filter' do
      before do
        create(:customers_auth, ip: '127.0.0.0/8')
        create(:customers_auth, ip: '192.168.0.0/16')
        create(:customers_auth, ip: '2001:67c:1324:111::1/64')
      end

      it 'returns all CIDRs in lega_sip_ips' do
        subject
        expect(body['lega_sip_ips']).to match_array(['127.0.0.0/8', '192.168.0.0/16', '2001:67c:1324:111::/64'])
        expect(body['lega_rtp_ips']).to eq([])
      end
    end

    context 'with lega_sip_min_ipv4_mask = 24' do
      before do
        allow(YetiConfig).to receive(:ip_access).and_return(
          double(lega_sip_min_ipv4_mask: 24, lega_sip_min_ipv6_mask: nil,
                 lega_rtp_min_ipv4_mask: nil, lega_rtp_min_ipv6_mask: nil,
                 cdr_lookback_days: nil)
        )
        create(:customers_auth, ip: '0.0.0.0/0')         # rejected
        create(:customers_auth, ip: '10.0.0.0/8')        # rejected
        create(:customers_auth, ip: '192.168.1.0/24')    # accepted
        create(:customers_auth, ip: '203.0.113.5/32')    # accepted
      end

      it 'drops CIDRs whose mask is shorter than 24' do
        subject
        expect(body['lega_sip_ips']).to match_array(['192.168.1.0/24', '203.0.113.5/32'])
      end
    end

    context 'with lega_sip_min_ipv6_mask = 64' do
      before do
        allow(YetiConfig).to receive(:ip_access).and_return(
          double(lega_sip_min_ipv4_mask: nil, lega_sip_min_ipv6_mask: 64,
                 lega_rtp_min_ipv4_mask: nil, lega_rtp_min_ipv6_mask: nil,
                 cdr_lookback_days: nil)
        )
        create(:customers_auth, ip: '2001:db8::/32')       # rejected
        create(:customers_auth, ip: '2001:db8:abcd::/48')  # rejected
        create(:customers_auth, ip: '2001:db8:abcd::/64')  # accepted
        create(:customers_auth, ip: '2001:db8:abcd::1/128') # accepted
      end

      it 'drops IPv6 CIDRs whose mask is shorter than 64' do
        subject
        expect(body['lega_sip_ips']).to match_array(['2001:db8:abcd::/64', '2001:db8:abcd::1/128'])
      end
    end

    context 'with gateways referenced from CustomersAuth and no mask filter' do
      before do
        gw1 = create(:gateway, rtp_acl: ['198.51.100.0/24', '203.0.113.5/32'])
        gw2 = create(:gateway, rtp_acl: ['2001:db8::/64'])
        create(:customers_auth, gateway: gw1)
        create(:customers_auth, gateway: gw2)
      end

      it 'returns flattened rtp_acl entries in lega_rtp_ips' do
        subject
        expect(body['lega_rtp_ips']).to match_array(
          ['198.51.100.0/24', '203.0.113.5/32', '2001:db8::/64']
        )
      end
    end

    context 'with gateways that have nil or empty rtp_acl' do
      before do
        gw_nil = create(:gateway, rtp_acl: nil)
        gw_empty = create(:gateway, rtp_acl: [])
        gw_with = create(:gateway, rtp_acl: ['198.51.100.0/24'])
        create(:customers_auth, gateway: gw_nil)
        create(:customers_auth, gateway: gw_empty)
        create(:customers_auth, gateway: gw_with)
      end

      it 'skips gateways without rtp_acl entries' do
        subject
        expect(body['lega_rtp_ips']).to match_array(['198.51.100.0/24'])
      end
    end

    context 'with duplicate rtp_acl entries across gateways' do
      before do
        gw1 = create(:gateway, rtp_acl: ['198.51.100.0/24'])
        gw2 = create(:gateway, rtp_acl: ['198.51.100.0/24', '203.0.113.0/24'])
        create(:customers_auth, gateway: gw1)
        create(:customers_auth, gateway: gw2)
      end

      it 'deduplicates the output' do
        subject
        expect(body['lega_rtp_ips']).to match_array(['198.51.100.0/24', '203.0.113.0/24'])
      end
    end

    context 'with a gateway that is not referenced by any CustomersAuth' do
      before do
        create(:gateway, rtp_acl: ['198.51.100.0/24']) # not referenced
        gw = create(:gateway, rtp_acl: ['203.0.113.0/24'])
        create(:customers_auth, gateway: gw)
      end

      it 'ignores unreferenced gateways' do
        subject
        expect(body['lega_rtp_ips']).to match_array(['203.0.113.0/24'])
      end
    end

    context 'with lega_rtp_min_ipv4_mask = 24 and lega_rtp_min_ipv6_mask = 64' do
      before do
        allow(YetiConfig).to receive(:ip_access).and_return(
          double(lega_sip_min_ipv4_mask: nil, lega_sip_min_ipv6_mask: nil,
                 lega_rtp_min_ipv4_mask: 24, lega_rtp_min_ipv6_mask: 64,
                 cdr_lookback_days: nil)
        )
        gw = create(:gateway, rtp_acl: [
                      '0.0.0.0/0',         # rejected
                      '10.0.0.0/8',        # rejected
                      '192.168.1.0/24',    # accepted
                      '203.0.113.5/32',    # accepted
                      '2001:db8::/32',     # rejected
                      '2001:db8:abcd::/64' # accepted
                    ])
        create(:customers_auth, gateway: gw)
      end

      it 'applies the rtp-specific mask filter' do
        subject
        expect(body['lega_rtp_ips']).to match_array(
          ['192.168.1.0/24', '203.0.113.5/32', '2001:db8:abcd::/64']
        )
      end
    end

    context 'when signaling and rtp mask filters are configured independently' do
      before do
        allow(YetiConfig).to receive(:ip_access).and_return(
          double(lega_sip_min_ipv4_mask: 24, lega_sip_min_ipv6_mask: nil,
                 lega_rtp_min_ipv4_mask: 32, lega_rtp_min_ipv6_mask: nil,
                 cdr_lookback_days: nil)
        )
        gw = create(:gateway, rtp_acl: ['192.168.1.0/24', '203.0.113.5/32'])
        create(:customers_auth, ip: '192.168.1.0/24', gateway: gw) # accepted in sip (>= /24)
        create(:customers_auth, ip: '10.0.0.0/8') # rejected in sip (< /24)
      end

      it 'filters each list with its own threshold' do
        subject
        expect(body['lega_sip_ips']).to match_array(['192.168.1.0/24'])
        expect(body['lega_rtp_ips']).to match_array(['203.0.113.5/32'])
      end
    end

    context 'when ClickHouse is enabled', freeze_time: true do
      let(:expected_cdr_since) { 7.days.ago.utc.strftime('%Y-%m-%d %H:%M:%S') }

      before do
        # Restore real config so the WebMock URL matches the configured ClickHouse URL.
        allow(ClickHouse).to receive(:config).and_call_original

        create(:customers_auth, ip: '10.0.0.0/24')

        stub_request(:post, ClickHouse.config.url)
          .with(
            basic_auth: [ClickHouse.config.username, ClickHouse.config.password],
            query: hash_including(
              database: ClickHouse.config.database,
              query: a_string_matching(/SELECT DISTINCT auth_orig_ip.*FROM cdrs.*time_start > '#{Regexp.escape(expected_cdr_since)}'.*duration > 0/m)
            )
          ).to_return(
            status: 200,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
            body: {
              meta: [{ name: 'auth_orig_ip', type: 'String' }],
              data: [
                { 'auth_orig_ip' => '203.0.113.10' },
                { 'auth_orig_ip' => '203.0.113.11' },
                { 'auth_orig_ip' => '10.0.0.5' } # inside 10.0.0.0/24 — kept distinct from the CIDR
              ],
              rows: 3
            }.to_json
          )
      end

      it 'merges CustomersAuth CIDRs with last-7d successful CDR source IPs in lega_sip_ips' do
        subject
        expect(body['lega_sip_ips']).to match_array([
                                                      '10.0.0.0/24',
                                                      '203.0.113.10/32',
                                                      '203.0.113.11/32',
                                                      '10.0.0.5/32'
                                                    ])
      end

      context 'when cdr_lookback_days is 0' do
        before do
          allow(YetiConfig).to receive(:ip_access).and_return(
            double(lega_sip_min_ipv4_mask: nil, lega_sip_min_ipv6_mask: nil,
                   lega_rtp_min_ipv4_mask: nil, lega_rtp_min_ipv6_mask: nil,
                   cdr_lookback_days: 0)
          )
        end

        it 'does not query ClickHouse and returns only CustomersAuth IPs' do
          subject
          expect(body['lega_sip_ips']).to match_array(['10.0.0.0/24'])
          expect(WebMock).not_to have_requested(:post, ClickHouse.config.url)
        end
      end

      context 'when ClickHouse query raises' do
        before do
          allow(ClickHouse.connection).to receive(:execute).and_raise(StandardError.new('boom'))
        end

        it 'logs the error and returns only CustomersAuth IPs' do
          expect(Rails.logger).to receive(:error).with(/ClickHouse fetch failed/)
          subject
          expect(body['lega_sip_ips']).to match_array(['10.0.0.0/24'])
        end

        context 'with prometheus enabled' do
          before { allow(PrometheusConfig).to receive(:enabled?).and_return(true) }

          it 'increments the clickhouse error counter' do
            expect(IpAccessProcessor).to receive(:collect_clickhouse_error_metric)
            subject
          end
        end

        context 'with prometheus disabled' do
          before { allow(PrometheusConfig).to receive(:enabled?).and_return(false) }

          it 'does not touch the prometheus processor' do
            expect(IpAccessProcessor).not_to receive(:collect_clickhouse_error_metric)
            subject
          end
        end
      end
    end

    context 'when ClickHouse is disabled (config.url is nil)' do
      before do
        create(:customers_auth, ip: '10.0.0.0/24')
      end

      it 'does not query ClickHouse' do
        subject
        expect(body['lega_sip_ips']).to match_array(['10.0.0.0/24'])
        expect(WebMock).not_to have_requested(:post, /clickhouse/)
      end
    end

    context 'when api.system.token is configured' do
      let(:token) { 'super-secret-token' }

      before do
        allow(YetiConfig).to receive(:api).and_return(double(system: double(token: token)))
        create(:customers_auth, ip: '10.0.0.0/24')
      end

      it 'returns 401 when no token is presented' do
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to be_blank
      end

      it 'returns 401 on a wrong token' do
        request.headers['Authorization'] = 'Bearer wrong'
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it 'serves the data with the correct Authorization: Bearer header' do
        request.headers['Authorization'] = "Bearer #{token}"
        subject
        expect(response).to have_http_status(:ok)
        expect(body['lega_sip_ips']).to match_array(['10.0.0.0/24'])
      end

      it 'serves the data with ?token= query string' do
        get :index, params: { format: :json, token: token }
        expect(response).to have_http_status(:ok)
        expect(body['lega_sip_ips']).to match_array(['10.0.0.0/24'])
      end
    end

    context 'when api.system.token is not configured' do
      before do
        allow(YetiConfig).to receive(:api).and_return(double(system: nil))
        create(:customers_auth, ip: '10.0.0.0/24')
      end

      it 'serves data without auth (preserves historical behaviour)' do
        subject
        expect(response).to have_http_status(:ok)
        expect(body['lega_sip_ips']).to match_array(['10.0.0.0/24'])
      end
    end
  end
end
