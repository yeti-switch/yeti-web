# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.dtmf_receive_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class System::DtmfReceiveMode < Yeti::ActiveRecord
  self.table_name = 'class4.dtmf_receive_modes'
end
