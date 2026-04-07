# frozen_string_literal: true

RSpec.describe 'switch22.load_aleg_gateway_attributes_cache' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_aleg_gateway_attributes_cache()'
  end

  let!(:gws) do
    [
      create(:gateway,
             ice_mode_id: 2,
             rtcp_mux_mode_id: 0,
             rtcp_feedback_mode_id: 2,
             allowed_methods: %w[INVITE ACK],
             supported_tags: %w[100rel timer])
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         gws.map do |gw|
                           {
                             id: gw.id,
                             ice_mode_id: gw.ice_mode_id,
                             rtcp_mux_mode_id: gw.rtcp_mux_mode_id,
                             rtcp_feedback_mode_id: gw.rtcp_feedback_mode_id,
                             allowed_methods: PG::TextEncoder::Array.new.encode(gw.allowed_methods),
                             supported_tags: PG::TextEncoder::Array.new.encode(gw.supported_tags)
                           }
                         end
                       )
  end

  context 'when allowed_methods and supported_tags are not set' do
    let!(:gws) do
      [create(:gateway, allowed_methods: nil, supported_tags: nil)]
    end

    it 'returns NULL for allowed_methods and supported_tags' do
      expect(subject.first[:allowed_methods]).to be_nil
      expect(subject.first[:supported_tags]).to be_nil
    end
  end

  context 'when allowed_methods and supported_tags are set to empty string' do
    let!(:gws) do
      [create(:gateway, allowed_methods: '', supported_tags: '')]
    end

    it 'returns NULL for allowed_methods and supported_tags' do
      expect(subject.first[:allowed_methods]).to be_nil
      expect(subject.first[:supported_tags]).to be_nil
    end
  end
end
