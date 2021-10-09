# frozen_string_literal: true

# == Schema Information
#
# Table name: stir_shaken_trusted_repositories
#
#  id                         :integer(2)       not null, primary key
#  url_pattern                :string           not null
#  validate_https_certificate :boolean          default(TRUE), not null
#  updated_at                 :datetime
#
class Equipment::StirShaken::TrustedRepository < ApplicationRecord
  self.table_name = 'stir_shaken_trusted_repositories'

  after_save { self.class.increment_state_sequence }
  after_destroy { self.class.increment_state_sequence }

  def self.increment_state_sequence
    SqlCaller::Yeti.execute("SELECT nextval('class4.stir_shaken_trusted_repositories_state_seq')")
  end

  def self.state_sequence
    SqlCaller::Yeti.select_value('SELECT last_value FROM class4.stir_shaken_trusted_repositories_state_seq')
  end
end
