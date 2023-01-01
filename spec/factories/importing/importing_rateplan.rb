# frozen_string_literal: true

FactoryBot.define do
  factory :importing_rateplan, class: Importing::Rateplan do
    o_id { nil }
    error_string { nil }

    name { nil }

    profit_control_mode_id { Routing::RateProfitControlMode::MODE_PER_CALL }
    profit_control_mode_name { Routing::RateProfitControlMode::MODES[Routing::RateProfitControlMode::MODE_PER_CALL] }
  end
end
