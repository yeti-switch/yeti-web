# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.config
#
#  id                              :integer(2)       not null, primary key
#  customer_amount_round_precision :integer(2)       default(5), not null
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

class System::CdrConfig < Cdr::Base
  self.table_name = 'sys.config'

  include WithPaperTrail

  belongs_to :call_duration_round_mode, class_name: 'System::CdrRoundMode', foreign_key: :call_duration_round_mode_id
  belongs_to :customer_price_round_mode, class_name: 'System::CdrPriceRoundMode', foreign_key: :customer_amount_round_mode_id
  belongs_to :vendor_price_round_mode, class_name: 'System::CdrPriceRoundMode', foreign_key: :vendor_amount_round_mode_id

  validates :call_duration_round_mode, :customer_price_round_mode, :vendor_price_round_mode, presence: true
  validates :customer_amount_round_precision, :vendor_amount_round_precision, presence: true

  validates :customer_amount_round_precision, :vendor_amount_round_precision,
                            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10, only_integer: true, allow_nil: false }

  def display_name
    id.to_s
  end
end
