# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.package_counters
#
#  id         :bigint(8)        not null, primary key
#  duration   :integer(4)       default(0), not null
#  exclude    :boolean          default(FALSE), not null
#  prefix     :string           not null
#  account_id :integer(4)       not null
#  service_id :bigint(8)
#
# Indexes
#
#  package_counters_account_id_idx  (account_id)
#  package_counters_prefix_idx      (((prefix)::prefix_range)) USING gist
#  package_counters_service_id_idx  (service_id)
#
# Foreign Keys
#
#  package_counters_account_id_fkey  (account_id => accounts.id)
#
class Billing::PackageCounter < ApplicationRecord
  self.table_name = 'billing.package_counters'

  belongs_to :account, class_name: 'Account'
  belongs_to :service, class_name: 'Billing::Service', optional: true

  validates :duration, presence: true
  validates :duration, allow_nil: true, numericality: { only_integer: true }
  validates :exclude, inclusion: { in: [true, false] }

  before_save { self.prefix ||= '' }

  def display_name
    "PC##{id}"
  end
end
