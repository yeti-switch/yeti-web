# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_codec_groups
#
#  id           :integer          not null, primary key
#  o_id         :integer
#  name         :string
#  error_string :string
#  is_changed   :boolean
#

class Importing::CodecGroup < Importing::Base
  self.table_name = 'data_import.import_codec_groups'
  attr_accessor :file

  self.import_attributes = ['name']

  import_for ::CodecGroup
end
