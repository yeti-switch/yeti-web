# frozen_string_literal: true

# == Schema Information
#
# Table name: logic_log
#
#  id        :bigint(8)        not null, primary key
#  level     :integer(4)       not null
#  msg       :text
#  source    :string           not null
#  timestamp :timestamptz      not null
#  txid      :bigint(8)        not null
#

class LogicLog < ApplicationRecord
  self.table_name = 'logic_log'

  def display_name
    id.to_s
  end
end
