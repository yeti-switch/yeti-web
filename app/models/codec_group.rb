# == Schema Information
#
# Table name: codec_groups
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class CodecGroup < ActiveRecord::Base
  has_paper_trail class_name: 'AuditLogItem'


  has_many :codec_group_codecs ,  inverse_of: :codec_group , dependent: :destroy
  has_many :codecs, through: :codec_group_codecs


  accepts_nested_attributes_for :codec_group_codecs, allow_destroy: true


  validates_uniqueness_of :name, allow_blank: false
  validates_presence_of :name
  validate :check_uniqueness_of_codecs

  def codec_names
    codec_group_codecs.sort { |c| c.priority }.map { |c| c.codec.name }
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

  protected
  def check_uniqueness_of_codecs
    codecs_tmp =  codec_group_codecs.to_a.reject { |c| c.marked_for_destruction?  }
    errors[:base] << "Empty Codecs" unless   codecs_tmp.length > 0
    errors[:base] << "Codec Group can't contain duplicated codecs" unless codecs_tmp.length == codecs_tmp.uniq { |obj| obj.codec_id }.length
  end

end
