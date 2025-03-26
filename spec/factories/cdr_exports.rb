# frozen_string_literal: true

# == Schema Information
#
# Table name: cdr_exports
#
#  id                  :integer(4)       not null, primary key
#  callback_url        :string
#  fields              :string           default([]), not null, is an Array
#  filters             :json             not null
#  rows_count          :integer(4)
#  status              :string           not null
#  time_format         :string           default("with_timezone"), not null
#  time_zone_name      :string
#  type                :string           not null
#  uuid                :uuid             not null
#  created_at          :datetime
#  updated_at          :datetime
#  customer_account_id :integer(4)
#
# Indexes
#
#  index_sys.cdr_exports_on_customer_account_id  (customer_account_id)
#  index_sys.cdr_exports_on_uuid                 (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_e796f29195  (customer_account_id => accounts.id)
#
FactoryBot.define do
  factory :cdr_export, class: 'CdrExport' do
    type { 'Base' }
    callback_url { nil }
    filters do
      {
        time_start_gteq: '2018-01-01',
        time_start_lteq: '2018-03-01'
      }
    end
    fields { %i[success id] }
    status { nil }

    trait :completed do
      status { CdrExport::STATUS_COMPLETED }
    end

    trait :failed do
      status { CdrExport::STATUS_FAILED }
    end

    trait :deleted do
      status { CdrExport::STATUS_DELETED }
    end
  end
end
