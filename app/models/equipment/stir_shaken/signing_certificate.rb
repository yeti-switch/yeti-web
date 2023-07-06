# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.stir_shaken_signing_certificates
#
#  id          :integer(2)       not null, primary key
#  certificate :string           not null
#  key         :string           not null
#  name        :string           not null
#  x5u         :string           not null
#  updated_at  :timestamptz
#
class Equipment::StirShaken::SigningCertificate < ApplicationRecord
  self.table_name = 'class4.stir_shaken_signing_certificates'

  validates :name, :certificate, :key, :x5u, presence: true

  include Yeti::StateUpdater
  self.state_name = 'stir_shaken_signing_certificates'
end
