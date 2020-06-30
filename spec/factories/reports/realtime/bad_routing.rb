# frozen_string_literal: true

FactoryBot.define do
  factory :bad_routing, class: Report::Realtime::BadRouting do
    time_start { Time.now.utc }

    trait :with_id do
      id { Cdr::Cdr.connection.select_value("SELECT nextval('cdr.cdr_id_seq')").to_i }
    end

    trait :with_id_and_uuid do
      id { Cdr::Cdr.connection.select_value("SELECT nextval('cdr.cdr_id_seq')").to_i }
      uuid { SecureRandom.uuid }
    end
  end
end
