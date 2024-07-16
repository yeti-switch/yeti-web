# frozen_string_literal: true

# == Schema Information
#
# Table name: import_rateplans
#
#  id                       :bigint(8)        not null, primary key
#  error_string             :string
#  is_changed               :boolean
#  name                     :string
#  profit_control_mode_name :string
#  o_id                     :integer(4)
#  profit_control_mode_id   :integer(4)
#
FactoryBot.define do
  factory :importing_rateplan, class: 'Importing::Rateplan' do
    o_id { nil }
    error_string { nil }

    name { nil }

    profit_control_mode_id { Routing::RateProfitControlMode::MODE_PER_CALL }
    profit_control_mode_name { Routing::RateProfitControlMode::MODES[Routing::RateProfitControlMode::MODE_PER_CALL] }
  end
end
