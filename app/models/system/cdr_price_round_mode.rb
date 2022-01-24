# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.amount_round_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  amount_round_modes_name_key  (name) UNIQUE
#

class System::CdrPriceRoundMode < Cdr::Base
  self.table_name = 'sys.amount_round_modes'

  validates :name, presence: true, uniqueness: true
end
