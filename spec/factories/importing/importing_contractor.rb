# frozen_string_literal: true

FactoryBot.define do
  factory :importing_contractor, class: Importing::Contractor do
    o_id { nil }
    error_string { nil }

    name { nil }
    enabled { true }
    vendor { false }
    customer { false }

    smtp_connection_name do
      System::SmtpConnection.take.try(:name) || create(:smtp_connection).name
    end
  end
end
