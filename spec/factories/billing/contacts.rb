# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.contacts
#
#  id            :integer(4)       not null, primary key
#  email         :string           not null
#  notes         :string
#  created_at    :timestamptz
#  updated_at    :timestamptz
#  admin_user_id :integer(4)
#  contractor_id :integer(4)
#
# Indexes
#
#  contacts_contractor_id_idx  (contractor_id)
#
# Foreign Keys
#
#  contacts_admin_user_id_fkey  (admin_user_id => admin_users.id)
#  contacts_contractor_id_fkey  (contractor_id => contractors.id)
#
FactoryBot.define do
  factory :contact, class: 'Billing::Contact' do
    sequence(:email) { |n| "rspec_mail_#{n}@example.com" }

    association :contractor, factory: :customer

    trait :filled do
      association :contractor, factory: :customer
      admin_user { build(:admin_user, :filled) }
    end
  end
end
