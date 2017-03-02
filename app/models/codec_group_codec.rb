# == Schema Information
#
# Table name: codec_group_codecs
#
#  id                   :integer          not null, primary key
#  codec_group_id       :integer          not null
#  codec_id             :integer          not null
#  priority             :integer          default(100), not null
#  dynamic_payload_type :integer
#  format_parameters    :string
#

class CodecGroupCodec < ActiveRecord::Base

  belongs_to :codec_group
  belongs_to :codec

  has_paper_trail class_name: 'AuditLogItem'

  validates_uniqueness_of :priority, scope: [:codec_group_id]
  validates_numericality_of :priority
  validates_uniqueness_of :codec_id, scope: [:codec_group_id]
  validates_presence_of :codec, :codec_group
  validates_numericality_of :dynamic_payload_type, greater_than: 95, less_than: 128, allow_nil: true, only_integer: true



  def display_name
    "#{self.id} #{self.codec.name}"
  end

  include Yeti::CodecReloader


end
