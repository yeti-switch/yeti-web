# == Schema Information
#
# Table name: class4.gateway_inband_dtmf_filtering_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Equipment::GatewayInbandDtmfFilteringMode < Yeti::ActiveRecord
  self.table_name='class4.gateway_inband_dtmf_filtering_modes'

end
