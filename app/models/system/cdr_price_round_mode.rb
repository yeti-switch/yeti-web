# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.amount_round_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class System::CdrPriceRoundMode < Cdr::Base
  self.table_name = 'sys.amount_round_modes'
end
