# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.call_duration_round_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class System::CdrRoundMode < Cdr::Base
  self.table_name = 'sys.call_duration_round_modes'
end
