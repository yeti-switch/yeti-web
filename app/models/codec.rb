# frozen_string_literal: true

# == Schema Information
#
# Table name: codecs
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  codecs_name_key  (name) UNIQUE
#

class Codec < ActiveRecord::Base
  has_many :codec_group_codecs
  has_many :codec_groups
end
