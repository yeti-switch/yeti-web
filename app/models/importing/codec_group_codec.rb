# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_codec_group_codecs
#
#  id               :integer          not null, primary key
#  o_id             :integer
#  codec_group_name :string
#  codec_group_id   :integer
#  codec_name       :string
#  codec_id         :integer
#  priority         :integer
#  error_string     :string
#

class Importing::CodecGroupCodec < Importing::Base
  self.table_name = 'data_import.import_codec_group_codecs'
  attr_accessor :file

  belongs_to :codec_group, class_name: '::CodecGroup'
  belongs_to :codec, class_name: '::Codec'

  self.import_attributes = %w[codec_group_id codec_id priority]

  self.import_class = ::CodecGroupCodec
end
