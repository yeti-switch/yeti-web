# frozen_string_literal: true

RSpec.describe 'switch22.load_gateway_attributes_cache' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_gateway_attributes_cache()'
  end

  let!(:gtp) do
    create(:gateway_throttling_profile)
  end

  let!(:gws) do
    [
      create(:gateway,
             throttling_profile: gtp,
             transfer_append_headers_req: ['x-yeti-auth: 12.3.4', 'x-key: value'],
             transfer_tel_uri_host: 'redirect.example.com')
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         gws.map do |gw|
                           {
                             id: gw.id,
                             throttling_codes: PG::TextEncoder::Array.new.encode(gtp.codes),
                             throttling_threshold_start: gtp.threshold_start,
                             throttling_threshold_end: gtp.threshold_end,
                             throttling_minimum_calls: gtp.minimum_calls,
                             throttling_window: gtp.window,
                             transfer_append_headers_req: PG::TextEncoder::Array.new.encode(gw.transfer_append_headers_req),
                             transfer_tel_uri_host: gw.transfer_tel_uri_host
                           }
                         end
                       )
  end
end
