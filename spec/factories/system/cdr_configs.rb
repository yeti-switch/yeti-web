# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.config
#
#  id                              :integer(2)       not null, primary key
#  customer_amount_round_precision :integer(2)       default(5), not null
#  disable_realtime_statistics     :boolean          default(FALSE), not null
#  vendor_amount_round_precision   :integer(2)       default(5), not null
#  call_duration_round_mode_id     :integer(2)       default(1), not null
#  customer_amount_round_mode_id   :integer(2)       default(1), not null
#  vendor_amount_round_mode_id     :integer(2)       default(1), not null
#
# Foreign Keys
#
#  config_call_duration_round_mode_id_fkey    (call_duration_round_mode_id => sys.call_duration_round_modes.id)
#  config_customer_amount_round_mode_id_fkey  (customer_amount_round_mode_id => sys.amount_round_modes.id)
#  config_vendor_amount_round_mode_id_fkey    (vendor_amount_round_mode_id => sys.amount_round_modes.id)
#
FactoryBot.define do
  factory :cdr_config, class: System::CdrConfig do
    sequence(:id) { |n| n }

    call_duration_round_mode { System::CdrRoundMode.take || create(:cdr_round_mode, :always_up) }
    customer_price_round_mode { System::CdrPriceRoundMode.take || create(:cdr_price_round_mode, :always_up) }
    vendor_price_round_mode { System::CdrPriceRoundMode.take || create(:cdr_price_round_mode, :always_up) }
  end
end
