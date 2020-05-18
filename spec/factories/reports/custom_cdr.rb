# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report
#
#  id          :integer          not null, primary key
#  date_start  :datetime
#  date_end    :datetime
#  filter      :string
#  group_by    :string
#  created_at  :datetime
#  customer_id :integer
#

FactoryBot.define do
  factory :custom_cdr, class: Report::CustomCdr do
    date_start { Time.now.utc }
    date_end { Time.now.utc + 1.week }
    filter { '' }
    group_by_fields { %w[customer_id rateplan_id] }
    association :customer, factory: :customer
  end
end
