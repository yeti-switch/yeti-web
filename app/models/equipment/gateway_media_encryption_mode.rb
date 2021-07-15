# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.gateway_media_encryption_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  gateway_media_encryption_modes_name_key  (name) UNIQUE
#

class Equipment::GatewayMediaEncryptionMode < ApplicationRecord
  self.table_name = 'class4.gateway_media_encryption_modes'
end
