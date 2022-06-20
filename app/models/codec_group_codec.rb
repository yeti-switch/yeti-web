# frozen_string_literal: true

# == Schema Information
#
# Table name: codec_group_codecs
#
#  id                   :integer(4)       not null, primary key
#  dynamic_payload_type :integer(4)
#  format_parameters    :string
#  priority             :integer(4)       default(100), not null
#  codec_group_id       :integer(4)       not null
#  codec_id             :integer(4)       not null
#
# Indexes
#
#  codec_group_codecs_codec_group_id_codec_id_key  (codec_group_id,codec_id) UNIQUE
#  codec_group_codecs_codec_group_id_priority_key  (codec_group_id,priority) UNIQUE
#
# Foreign Keys
#
#  codec_group_codecs_codec_group_id_fkey  (codec_group_id => codec_groups.id)
#  codec_group_codecs_codec_id_fkey        (codec_id => codecs.id)
#

class CodecGroupCodec < ApplicationRecord
  belongs_to :codec_group
  belongs_to :codec

  include WithPaperTrail

  validates :priority, uniqueness: { scope: [:codec_group_id] }
  validates :priority, numericality: true
  validates :codec_id, uniqueness: { scope: [:codec_group_id] }
  validates :codec, :codec_group, presence: true
  validates :dynamic_payload_type, numericality: { greater_than: 95, less_than: 128, allow_nil: true, only_integer: true }

  def display_name
    "#{id} #{codec.name}"
  end

  include Yeti::CodecReloader
  include Yeti::StateUpdater
  self.state_name = 'codec_groups'
end
