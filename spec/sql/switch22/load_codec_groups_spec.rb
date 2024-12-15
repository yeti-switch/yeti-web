# frozen_string_literal: true

RSpec.describe 'switch22.load_codec_groups' do
  subject do
    SqlCaller::Yeti.select_all(sql).map(&:deep_symbolize_keys)
  end

  let(:sql) do
    'SELECT * FROM switch22.load_codec_groups()'
  end
  let!(:codec_groups) do
    [
      CodecGroup.find(1),
      create(:codec_group, ptime: nil),
      create(:codec_group, ptime: 20)
    ]
  end

  it 'responds with correct codec_groups' do
    expect(subject).to match_array(
                         codec_groups.map do |c|
                           {
                             id: c.id,
                             ptime: c.ptime,
                             codecs: a_kind_of(String)
                           }
                         end
                       )
  end

  it 'responds with correct codecs inside codec_groups', :aggregate_failures do
    subject.each do |row|
      codec_group = codec_groups.detect { |c| c.id == row[:id] }
      actual_codecs = JSON.parse(row[:codecs], symbolize_names: true)
      expect(actual_codecs).to match_array(
        codec_group.codec_group_codecs.map do |codec_group_codec|
          codec = codec_group_codec.codec
          {
            id: codec.id,
            name: codec.name,
            priority: codec_group_codec.priority,
            dynamic_payload_type: codec_group_codec.dynamic_payload_type,
            format_parameters: codec_group_codec.format_parameters
          }
        end
      )
    end
  end
end
