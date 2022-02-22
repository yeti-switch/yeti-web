# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_custom_report
#
#  id          :integer(4)       not null, primary key
#  completed   :boolean          default(FALSE), not null
#  date_end    :datetime
#  date_start  :datetime
#  filter      :string
#  group_by    :string           is an Array
#  send_to     :integer(4)       is an Array
#  created_at  :datetime
#  customer_id :integer(4)
#
# Indexes
#
#  cdr_custom_report_id_idx  (id) UNIQUE WHERE (id IS NOT NULL)
#

FactoryBot.define do
  factory :custom_cdr, class: Report::CustomCdr do
    date_start { Time.now.utc }
    date_end { Time.now.utc + 1.week }
    group_by { %w[customer_id rateplan_id] }

    trait :completed do
      completed { true }
    end

    trait :with_send_to do
      send_to do
        [
          FactoryBot.create(:contact).id,
          FactoryBot.create(:contact).id
        ]
      end
    end

    trait :with_customer do
      association :customer, factory: :customer
    end
  end
end
