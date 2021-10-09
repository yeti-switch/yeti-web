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

  after_save { self.class.increment_state_sequence }
  after_destroy { self.class.increment_state_sequence }

  def self.increment_state_sequence
    SqlCaller::Yeti.execute("SELECT nextval('class4.stir_shaken_trusted_certificates_state_seq')")
  end

  def self.state_sequence
    SqlCaller::Yeti.select_value('SELECT last_value FROM class4.stir_shaken_trusted_certificates_state_seq')
  end
end
