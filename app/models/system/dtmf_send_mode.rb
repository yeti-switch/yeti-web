# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.dtmf_send_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class System::DtmfSendMode < Yeti::ActiveRecord
  self.table_name = 'class4.dtmf_send_modes'
end
