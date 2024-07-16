# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases
#
#  id                                                                                   :integer(2)       not null, primary key
#  cache_ttl                                                                            :integer(4)       default(10800), not null
#  database_type(One of Lnp::DatabaseThinq, Lnp::DatabaseSipRedirect, Lnp::DatabaseCsv) :string
#  name                                                                                 :string           not null
#  created_at                                                                           :timestamptz
#  database_id                                                                          :integer(2)       not null
#
# Indexes
#
#  index_class4.lnp_databases_on_database_id_and_database_type  (database_id,database_type) UNIQUE
#  lnp_databases_name_key                                       (name) UNIQUE
#

FactoryBot.define do
  factory :lnp_database, class: 'Lnp::Database' do
    sequence(:name) { |n| "LNP Database #{n}" }
    cache_ttl { 120 }

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

    trait :sip_redirect do
      database_attributes do
        {
          type: Lnp::Database::CONST::TYPE_SIP_REDIRECT,
          host: 'sip.example.com',
          port: 6050,
          timeout: 300,
          format_id: 1
        }
      end
    end

    trait :csv do
      database_attributes do
        {
          type: Lnp::Database::CONST::TYPE_CSV,
          csv_file_path: '/tmp/lnp.csv'
        }
      end
    end

    trait :alcazar do
      database_attributes do
        {
          type: Lnp::Database::CONST::TYPE_ALCAZAR,
          host: 'rspec.example.com',
          port: 1239,
          timeout: 600,
          key: 'lnp-key'
        }
      end
    end

    trait :coure_anq do
      database_attributes do
        {
          type: Lnp::Database::CONST::TYPE_COURE_ANQ,
          base_url: 'http://lnp.rspec.example.com/api',
          username: 'rspec.test.name',
          password: 'rspec.test.password',
          country_code: 'UA',
          operators_map: '{"operator1": "tag1", "operator2": "tag2"}'
        }
      end
    end
  end
end
