# == Schema Information
#
# Table name: billing.package_configs
#
#  id         :integer          not null, primary key
#  package_id :integer          not null
#  prefix     :string           default(""), not null
#  amount     :integer          default(0), not null
#

class Billing::PackageConfig < Yeti::ActiveRecord
  self.table_name = 'billing.package_configs'

  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :package, class_name: 'Billing::Package', foreign_key: :package_id

  validates_presence_of :prefix, :package, :amount
end
