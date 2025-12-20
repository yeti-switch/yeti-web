# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_codec_groups
#
#  id           :bigint(8)        not null, primary key
#  error_string :string
#  is_changed   :boolean
#  name         :string
#  o_id         :integer(4)
#

class Importing::CodecGroup < Importing::Base
  self.table_name = 'data_import.import_codec_groups'
  attr_accessor :file

  self.import_attributes = %w[name]
  self.strict_unique_attributes = %w[name]

  import_for ::CodecGroup
end
