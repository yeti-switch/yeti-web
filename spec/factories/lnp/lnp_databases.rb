# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  created_at    :datetime
#  database_type :string
#  database_id   :integer          not null
#

FactoryGirl.define do
  factory :lnp_database, class: Lnp::Database do
    sequence(:name) { |n| "LNP Database #{n}" }

    trait :thinq do
      database_attributes do
        {
          type: Lnp::Database::CONST::TYPE_THINQ,
          host: 'rspec.example.com',
          port: 1239,
          username: 'rspec.test.name',
          token: 'rspecsecret'
        }
      end
    end
  end
end
