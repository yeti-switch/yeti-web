# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.config
#
#  id                              :integer          not null, primary key
#  call_duration_round_mode_id     :integer          default(1), not null
#  customer_amount_round_mode_id   :integer          default(1), not null
#  customer_amount_round_precision :integer          default(5), not null
#  vendor_amount_round_mode_id     :integer          default(1), not null
#  vendor_amount_round_precision   :integer          default(5), not null
#

FactoryBot.define do
  factory :cdr_config, class: System::CdrConfig do
    sequence(:id) { |n| n }

    call_duration_round_mode { System::CdrRoundMode.take || create(:cdr_round_mode, :always_up) }
    customer_price_round_mode { System::CdrPriceRoundMode.take || create(:cdr_price_round_mode, :always_up) }
    vendor_price_round_mode { System::CdrPriceRoundMode.take || create(:cdr_price_round_mode, :always_up) }
  end
end
