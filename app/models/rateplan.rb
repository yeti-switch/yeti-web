# == Schema Information
#
# Table name: class4.rateplans
#
#  id                     :integer          not null, primary key
#  name                   :string
#  profit_control_mode_id :integer          default("1"), not null
#  send_quality_alarms_to :integer          is an Array
#  uuid                   :uuid             not null
#

class Rateplan < ActiveRecord::Base
  self.table_name = 'class4.rateplans'

  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :profit_control_mode, class_name: 'Routing::RateProfitControlMode', foreign_key: 'profit_control_mode_id'
  has_many :customers_auths, dependent: :restrict_with_error
  has_many :destinations, class_name: Destination, foreign_key: :rateplan_id, dependent: :destroy

  scope :where_customer, -> (id) do
    joins(:customers_auths).where(CustomersAuth.table_name => { customer_id: id })
  end

  scope :where_account, -> (id) do
    joins(:customers_auths).where(CustomersAuth.table_name => { account_id: id })
  end

  validates_presence_of :name, :profit_control_mode
  validates_uniqueness_of :name, allow_blank: false

  validate do
    if self.send_quality_alarms_to.present?  and self.send_quality_alarms_to.any?
      self.errors.add(:send_quality_alarms_to, :invalid) if contacts.count != self.send_quality_alarms_to.count
    end
  end

  def display_name
    "#{self.name} | #{self.id}"
  end


  def send_quality_alarms_to=(send_to_ids)
    self[:send_quality_alarms_to] = send_to_ids.reject {|i| i.blank? }
  end

  def contacts
    @contacts ||= Billing::Contact.where(id: send_quality_alarms_to)
  end

end
  
