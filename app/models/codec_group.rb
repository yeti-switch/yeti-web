# frozen_string_literal: true

# == Schema Information
#
# Table name: codec_groups
#
#  id    :integer(4)       not null, primary key
#  name  :string           not null
#  ptime :integer(2)
#
# Indexes
#
#  codec_groups_name_key  (name) UNIQUE
#

class CodecGroup < ApplicationRecord
  include WithPaperTrail

  ALLOWED_PTIMES = [10, 20, 30, 40].freeze

  has_many :codec_group_codecs, inverse_of: :codec_group, dependent: :destroy
  has_many :codecs, through: :codec_group_codecs

  accepts_nested_attributes_for :codec_group_codecs, allow_destroy: true

  validates :name, uniqueness: { allow_blank: false }
  validates :name, presence: true

  validates :ptime, inclusion: { in: ALLOWED_PTIMES, message: 'Ptime %<value>s is not allowed' }, allow_nil: true
  validate :check_uniqueness_of_codecs

  def codec_names
    codec_group_codecs.sort_by(&:priority).map { |c| c.codec.name }
  end
  # define_attribute_methods :codec_names
  # def codec_group_codecs_attributes=(attributes)
  #   count = codec_names.count
  #   result = assign_nested_attributes_for_collection_association(:codec_group_codecs, attributes)
  #   codec_names_will_change! unless codec_names.count != count
  #   result
  # end
  #

  def display_name
    self[:name]
  end

  include Yeti::CodecReloader
  include Yeti::StateUpdater
  self.state_names = ['codec_groups']

  protected

  def check_uniqueness_of_codecs
    codecs_tmp = codec_group_codecs.to_a.reject(&:marked_for_destruction?)
    errors.add(:base, 'Empty Codecs') if codecs_tmp.empty?
    errors.add(:base, "Codec Group can't contain duplicated codecs") unless codecs_tmp.length == codecs_tmp.uniq(&:codec_id).length
    errors.add(:base, "Codec Group can't contain codecs with the same priority") unless codecs_tmp.length == codecs_tmp.uniq(&:priority).length
  end
end
