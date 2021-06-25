# frozen_string_literal: true

# == Schema Information
#
# Table name: stir_shaken_trusted_certificates
#
#  id          :integer(2)       not null, primary key
#  certificate :string           not null
#  name        :string           not null
#  updated_at  :datetime
#
class Equipment::StirShaken::TrustedCertificate < Yeti::ActiveRecord
  self.table_name = 'stir_shaken_trusted_certificates'
end
