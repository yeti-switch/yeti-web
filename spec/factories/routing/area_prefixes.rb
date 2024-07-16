# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.area_prefixes
#
#  id      :bigint(8)        not null, primary key
#  prefix  :string           not null
#  area_id :integer(4)       not null
#
# Indexes
#
#  area_prefixes_prefix_key  (prefix) UNIQUE
#
# Foreign Keys
#
#  area_prefixes_area_id_fkey  (area_id => areas.id)
#
FactoryBot.define do
  factory :area_prefix, class: 'Routing::AreaPrefix' do
    sequence(:prefix) { |n| "#{n}#{n + 1}#{n + 2}" } # example: '123', '234'...

    association :area
  end
end
