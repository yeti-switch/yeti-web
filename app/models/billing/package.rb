# == Schema Information
#
# Table name: billing.packages
#
#  id                        :integer          not null, primary key
#  name                      :string           not null
#  price                     :decimal(, )      not null
#  billing_interval          :integer
#  allow_minutes_aggregation :boolean          default(FALSE), not null
#

class Billing::Package < Yeti::ActiveRecord
  self.table_name = 'billing.packages'

  has_paper_trail class_name: 'AuditLogItem'

  has_many :accounts, class_name: 'Account', foreign_key: :account_id, dependent: :restrict_with_error
  has_many :configurations, class_name: 'Billing::PackageConfig', foreign_key: :package_id, dependent: :destroy

  validates_presence_of :name, :price, :billing_interval
  validates_uniqueness_of :name

end
