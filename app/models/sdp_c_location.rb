# == Schema Information
#
# Table name: sdp_c_location
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class SdpCLocation < ActiveRecord::Base
  self.table_name = 'sdp_c_location'
end
