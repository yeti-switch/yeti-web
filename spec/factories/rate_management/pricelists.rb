# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.pricelists
#
#  id                           :integer(4)       not null, primary key
#  applied_at                   :datetime
#  apply_changes_in_progress    :boolean          default(FALSE), not null
#  detect_dialpeers_in_progress :boolean          default(FALSE), not null
#  filename                     :string           not null
#  items_count                  :integer(4)       default(0), not null
#  name                         :string           not null
#  retain_enabled               :boolean          default(FALSE), not null
#  retain_priority              :boolean          default(FALSE), not null
#  valid_from                   :datetime
#  valid_till                   :datetime         not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  project_id                   :integer(4)       not null
#  state_id                     :integer(2)       not null
#
# Indexes
#
#  index_ratemanagement.pricelists_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_bbdbad8a45  (project_id => ratemanagement.projects.id)
#
FactoryBot.define do
  factory :rate_management_pricelist, class: 'RateManagement::Pricelist' do
    sequence(:name) { |n| "Pricelist Name #{n}" }
    project_id { nil }
    state_id { RateManagement::Pricelist::CONST::STATE_ID_NEW }
    valid_till { 10.days.from_now.beginning_of_day.in_time_zone }
    filename { 'test_file.csv' }

    transient do
      items_qty { 0 }
    end

    after(:create) do |record, ev|
      if ev.items_qty > 0
        FactoryBot.create_list(
          :rate_management_pricelist_item,
          ev.items_qty,
          :filed_from_project,
          pricelist: record
        )
        record.update!(items_count: ev.items_qty)
      end
    end

    trait :with_project do
      project { association :rate_management_project, :filled, :with_routing_tags }
    end

    trait :new do
      state_id { RateManagement::Pricelist::CONST::STATE_ID_NEW }
    end

    trait :dialpeers_detected do
      state_id { RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED }
    end

    trait :applied do
      state_id { RateManagement::Pricelist::CONST::STATE_ID_APPLIED }
      applied_at { Time.now.utc }
    end
  end
end
