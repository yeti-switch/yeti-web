# frozen_string_literal: true

# == Schema Information
#
# Table name: contractors
#
#  id                 :integer(4)       not null, primary key
#  address            :string
#  customer           :boolean          not null
#  description        :string
#  enabled            :boolean          not null
#  name               :string           not null
#  phones             :string
#  vendor             :boolean          not null
#  external_id        :bigint(8)
#  smtp_connection_id :integer(4)
#
# Indexes
#
#  contractors_external_id_key  (external_id) UNIQUE
#  contractors_name_unique      (name) UNIQUE
#
# Foreign Keys
#
#  contractors_smtp_connection_id_fkey  (smtp_connection_id => smtp_connections.id)
#
FactoryBot.define do
  factory :contractor, class: 'Contractor' do
    sequence(:name) { |n| "contractor#{n}" }
    sequence(:external_id) { |n| n }
    enabled { true }
    vendor { false }
    customer { false }

    factory :customer do
      vendor { false }
      customer { true }
    end

    factory :vendor do
      vendor { true }
      customer { false }
    end
  end
end
