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

FactoryGirl.define do
  factory :logic_log, class: LogicLog do
    source 'Dialpeer (3)'
    level 0
    msg 'finished'
    txid 70_196_395
  end
end
