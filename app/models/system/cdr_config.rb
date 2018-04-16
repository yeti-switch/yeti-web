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

class System::CdrConfig < Cdr::Base
  self.table_name ='sys.config'

  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :call_duration_round_mode, class_name: 'System::CdrRoundMode', foreign_key: :call_duration_round_mode_id
  belongs_to :customer_price_round_mode, class_name: 'System::CdrPriceRoundMode', foreign_key: :customer_amount_round_mode_id
  belongs_to :vendor_price_round_mode, class_name: 'System::CdrPriceRoundMode', foreign_key: :vendor_amount_round_mode_id

  validates_presence_of :call_duration_round_mode, :customer_price_round_mode, :vendor_price_round_mode
  validates_presence_of :customer_amount_round_precision, :vendor_amount_round_precision

  validates_numericality_of :customer_amount_round_precision, :vendor_amount_round_precision,
                            greater_than_or_equal_to: 0, less_than_or_equal_to: 10, only_integer: true, allow_nil: false


  def display_name
    "#{self.id}"
  end

end
