# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.customer_portal_access_profiles
#
#  id                                   :integer(2)       not null, primary key
#  account                              :boolean          default(TRUE), not null
#  incoming_cdrs                        :boolean          default(TRUE), not null
#  incoming_statistics                  :boolean          default(TRUE), not null
#  invoices                             :boolean          default(TRUE), not null
#  name                                 :string           not null
#  outgoing_cdr_exports                 :boolean          default(TRUE), not null
#  outgoing_cdrs                        :boolean          default(TRUE), not null
#  outgoing_numberlists                 :boolean          default(TRUE), not null
#  outgoing_rateplans                   :boolean          default(TRUE), not null
#  outgoing_statistics                  :boolean          default(TRUE), not null
#  outgoing_statistics_acd              :boolean          default(TRUE), not null
#  outgoing_statistics_active_calls     :boolean          default(TRUE), not null
#  outgoing_statistics_asr              :boolean          default(TRUE), not null
#  outgoing_statistics_failed_calls     :boolean          default(TRUE), not null
#  outgoing_statistics_successful_calls :boolean          default(TRUE), not null
#  outgoing_statistics_total_calls      :boolean          default(TRUE), not null
#  outgoing_statistics_total_duration   :boolean          default(TRUE), not null
#  outgoing_statistics_total_price      :boolean          default(TRUE), not null
#  payments                             :boolean          default(TRUE), not null
#  services                             :boolean          default(TRUE), not null
#  transactions                         :boolean          default(TRUE), not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#
# Indexes
#
#  idx_customer_portal_access_profiles_name_index  (name) UNIQUE
#
module System
  class CustomerPortalAccessProfile < ApplicationRecord
    self.table_name = 'sys.customer_portal_access_profiles'

    has_many :api_accesses, dependent: :restrict_with_error

    validates :name, presence: true, uniqueness: true

    def display_name
      "#{name} | #{id}"
    end
  end
end
