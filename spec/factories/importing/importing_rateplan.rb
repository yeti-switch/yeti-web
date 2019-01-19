# frozen_string_literal: true

FactoryGirl.define do
  factory :importing_rateplan, class: Importing::Rateplan do
    transient do
      _profit_control_mode { Routing::RateProfitControlMode.first }
    end

    o_id nil
    error_string nil

    name nil

    profit_control_mode_id { _profit_control_mode.id }
    profit_control_mode_name { _profit_control_mode.name }
  end
end
