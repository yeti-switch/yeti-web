# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_media_encryption_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Equipment::GatewayMediaEncryptionMode < Yeti::ActiveRecord
  self.table_name = 'class4.gateway_media_encryption_modes'
end
