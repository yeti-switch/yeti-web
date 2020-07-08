# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.call_duration_round_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  call_duration_round_modes_name_key  (name) UNIQUE
#

class System::CdrRoundMode < Cdr::Base
  self.table_name = 'sys.call_duration_round_modes'
end
