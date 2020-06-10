# frozen_string_literal: true

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

  validates :priority, uniqueness: { scope: [:codec_group_id] }
  validates :priority, numericality: true
  validates :codec_id, uniqueness: { scope: [:codec_group_id] }
  validates :codec, :codec_group, presence: true
  validates :dynamic_payload_type, numericality: { greater_than: 95, less_than: 128, allow_nil: true, only_integer: true }

  def display_name
    "#{id} #{codec.name}"
  end

  include Yeti::CodecReloader
end
