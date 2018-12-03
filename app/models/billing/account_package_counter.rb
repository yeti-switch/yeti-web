# == Schema Information
#
# Table name: billing.account_package_counters
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  prefix     :string           default(""), not null
#  amount     :integer          default(0), not null
#  expired_at :datetime
#

class Billing::AccountPackageCounter < Yeti::ActiveRecord
  self.table_name = 'billing.account_package_counters'

  belongs_to :account, class_name: 'Account', foreign_key: :account_id

  validates :account_id, presence: true
  validates :prefix, uniqueness: { scope: :account_id }
end
