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

FactoryBot.define do
  factory :logic_log, class: 'LogicLog' do
    source { 'Dialpeer (3)' }
    level { 0 }
    msg { 'finished' }
    txid { 70_196_395 }
  end
end
