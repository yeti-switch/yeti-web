# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.destination_next_rates
#
#  id               :bigint(8)        not null, primary key
#  applied          :boolean          default(FALSE), not null
#  apply_time       :timestamptz
#  connect_fee      :decimal(, )      not null
#  initial_interval :integer(2)       not null
#  initial_rate     :decimal(, )      not null
#  next_interval    :integer(2)       not null
#  next_rate        :decimal(, )      not null
#  created_at       :timestamptz
#  updated_at       :timestamptz
#  destination_id   :bigint(8)        not null
#  external_id      :bigint(8)
#
# Indexes
#
#  destination_next_rates_destination_id_idx  (destination_id)
#
# Foreign Keys
#
#  destination_next_rates_destination_id_fkey  (destination_id => destinations.id)
#
FactoryBot.define do
  factory :destination_next_rate, class: 'Routing::DestinationNextRate' do
    initial_rate { 0 }
    next_rate { 0 }
    initial_interval { 5 }
    next_interval { 10 }
    connect_fee { 0 }
    apply_time { 1.hour.from_now }
    applied { false }

    association :destination

    trait :random do
      initial_rate { 0.04 + rand.round(2) }
      next_rate { 0.05 + rand.round(2) }
      connect_fee { 0.06 + rand.round(2) }
      initial_interval { rand(90..149) }
      next_interval { rand(120..179) }
    end
  end
end
