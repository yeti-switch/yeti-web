# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.dtmf_receive_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  dtmf_receive_modes_name_key  (name) UNIQUE
#

class System::DtmfReceiveMode < ApplicationRecord
  self.table_name = 'class4.dtmf_receive_modes'

  validates :name, presence: true, uniqueness: true
end
