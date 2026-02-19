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

  include WithPaperTrail
  include Equipment::StirShaken::CertificateDetails

  has_many :customers_auths, foreign_key: :stir_shaken_crt_id, dependent: :restrict_with_error
  has_many :gateways, foreign_key: :stir_shaken_crt_id, dependent: :restrict_with_error

  validates :name, :certificate, :key, :x5u, presence: true

  include Yeti::StateUpdater
  self.state_names = ['stir_shaken_signing_certificates']

  def display_name
    "#{name} | #{id}"
  end
end
