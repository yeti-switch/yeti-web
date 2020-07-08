# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.dtmf_send_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  dtmf_send_modes_name_key  (name) UNIQUE
#

class System::DtmfSendMode < Yeti::ActiveRecord
  self.table_name = 'class4.dtmf_send_modes'
end
