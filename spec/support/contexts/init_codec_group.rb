# frozen_string_literal: true

shared_context :init_codec_group do |_args|
  before do
    codec_group = CodecGroup.new(
      name: 'Most useful codecs',
      codec_group_codecs: [
        CodecGroupCodec.new(codec: Codec.find(13), priority: 110),
        CodecGroupCodec.new(codec: Codec.find(6),  priority: 140),
        CodecGroupCodec.new(codec: Codec.find(7),  priority: 150),
        CodecGroupCodec.new(codec: Codec.find(8),  priority: 160),
        CodecGroupCodec.new(codec: Codec.find(9),  priority: 180),
        CodecGroupCodec.new(codec: Codec.find(10), priority: 200)
      ]
    )
    codec_group.save
    @codec_group = CodecGroup.last
  end
end
