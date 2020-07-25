# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_codec_group_codecs
#
#  id               :bigint(8)        not null, primary key
#  codec_group_name :string
#  codec_name       :string
#  error_string     :string
#  is_changed       :boolean
#  priority         :integer(4)
#  codec_group_id   :integer(4)
#  codec_id         :integer(4)
#  o_id             :integer(4)
#

class Importing::CodecGroupCodec < Importing::Base
  self.table_name = 'data_import.import_codec_group_codecs'
  attr_accessor :file

  belongs_to :codec_group, class_name: '::CodecGroup'
  belongs_to :codec, class_name: '::Codec'

  self.import_attributes = %w[codec_group_id codec_id priority]

  import_for ::CodecGroupCodec
end
