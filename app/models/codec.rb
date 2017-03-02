# == Schema Information
#
# Table name: codecs
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Codec < ActiveRecord::Base

   has_many :codec_group_codecs
   has_many :codec_groups

end
