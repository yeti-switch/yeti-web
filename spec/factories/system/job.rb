# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.jobs
#
#  id                   :integer           not null, primary key
#  type                 :String
#  description          :String            default(TRUE), not null
#  updated_at           :datetime          default(TRUE), not null
#  running              :boolean           default(TRUE), not null
#

FactoryBot.define do
  factory :job, class: BaseJob do
    sequence(:type) { |n| "CdrPartitioning #{n}" }
    description { nil }
    running { false }
  end
end
