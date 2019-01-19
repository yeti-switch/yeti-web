# frozen_string_literal: true

# == Schema Information
#
# Table name: logic_log
#
#  id        :integer          not null, primary key
#  source    :string           not null
#  level     :integer          not null
#  msg       :text
#  txid      :integer          not null
#  timestamp :datetime         not null
#

class LogicLog < ActiveRecord::Base
  self.table_name = 'logic_log'

  def display_name
    id.to_s
 end
end
