# frozen_string_literal: true

RSpec.describe 'switch21.load_codec_groups' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch21.load_codec_groups()'
  end
  let!(:codec_groups) do
    [
      create(:codec_group)
    ]
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         codec_groups.map do |c|
                           {
                             id: c.id,
                             ptime: c.name,
                             codecs: c.codecs.to_json
                           }
                         end
                       )
  end
end
