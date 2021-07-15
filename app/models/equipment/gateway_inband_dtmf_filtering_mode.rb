# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_inband_dtmf_filtering_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  gateway_inband_dtmf_filtering_modes_name_key  (name) UNIQUE
#

class Equipment::GatewayInbandDtmfFilteringMode < ApplicationRecord
  self.table_name = 'class4.gateway_inband_dtmf_filtering_modes'
end
