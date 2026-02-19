# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.stir_shaken_trusted_certificates
#
#  id          :integer(2)       not null, primary key
#  certificate :string           not null
#  name        :string           not null
#  updated_at  :timestamptz
#
class Equipment::StirShaken::TrustedCertificate < ApplicationRecord
  self.table_name = 'class4.stir_shaken_trusted_certificates'

  include WithPaperTrail
  include Equipment::StirShaken::CertificateDetails

  validates :name, :certificate, presence: true

  include Yeti::StateUpdater
  self.state_names = ['stir_shaken_trusted_certificates']

  def display_name
    "#{name} | #{id}"
  end
end
