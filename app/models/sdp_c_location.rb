# frozen_string_literal: true

# == Schema Information
#
# Table name: sdp_c_location
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  sdp_c_location_name_key  (name) UNIQUE
#

class SdpCLocation < ActiveRecord::Base
  self.table_name = 'sdp_c_location'
end
