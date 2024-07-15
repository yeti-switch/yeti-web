# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_users
#
#  id                     :integer(4)       not null, primary key
#  allowed_ips            :inet             is an Array
#  current_sign_in_at     :timestamptz
#  current_sign_in_ip     :string(255)
#  enabled                :boolean          default(TRUE)
#  encrypted_password     :string(255)      default(""), not null
#  last_sign_in_at        :timestamptz
#  last_sign_in_ip        :string(255)
#  per_page               :json             not null
#  remember_created_at    :timestamptz
#  reset_password_sent_at :timestamptz
#  reset_password_token   :string(255)
#  roles                  :string           not null, is an Array
#  saved_filters          :json             not null
#  sign_in_count          :integer(4)       default(0)
#  stateful_filters       :boolean          default(FALSE), not null
#  username               :string           not null
#  visible_columns        :json             not null
#  created_at             :timestamptz      not null
#  updated_at             :timestamptz      not null
#
# Indexes
#
#  admin_users_username_idx                   (username) UNIQUE
#  admin_users_username_key                   (username) UNIQUE
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :admin_user, class: 'AdminUser' do
    sequence(:username) { |n| "admin#{n}" }
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { '111111' }
    roles { ['user'] }
    after(:build) do |admin|
      if admin.class.ldap?
        admin.encrypted_password = admin.encrypt_password(admin.password)
      end
    end

    trait :filled do
      association :billing_contact, factory: :contact
    end
  end
end
