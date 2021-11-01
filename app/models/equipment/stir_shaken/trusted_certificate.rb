# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.stir_shaken_trusted_certificates
#
#  id          :integer(2)       not null, primary key
#  certificate :string           not null
#  name        :string           not null
#  updated_at  :datetime
#
class Equipment::StirShaken::TrustedCertificate < ApplicationRecord
  self.table_name = 'class4.stir_shaken_trusted_certificates'

  include Yeti::StateSequenceUpdater
  self.state_sequence_name = 'class4.stir_shaken_trusted_certificates_state_seq'
end
