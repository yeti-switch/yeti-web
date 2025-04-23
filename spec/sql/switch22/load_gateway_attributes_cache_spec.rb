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
             allow_multipart_body: false,
             throttling_profile: gtp)
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         gws.map do |gw|
                           {
                             id: gw.id,
                             throttling_codes: gtp.codes,
                             throttling_threshold: gtp.threshold,
                             throttling_window: gtp.window,
                             allow_multipart_body: gw.allow_multipart_body
                           }
                         end
                       )
  end
end
