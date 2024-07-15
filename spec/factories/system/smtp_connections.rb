# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.smtp_connections
#
#  id            :integer(4)       not null, primary key
#  auth_password :string
#  auth_type     :string           default("plain"), not null
#  auth_user     :string
#  from_address  :string           not null
#  global        :boolean          default(TRUE), not null
#  host          :string           not null
#  name          :string           not null
#  port          :integer(4)       default(25), not null
#
# Indexes
#
#  smtp_connections_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :smtp_connection, class: 'System::SmtpConnection' do
    sequence(:name) { |n| "smtp_connection#{n}" }
    host { 'host' }
    port { '25' }
    from_address { 'address@email.com' }
    global { true }

    trait :filled do
      contractors { build_list :customer, 2 }
    end
  end
end
