# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_contractors
#
#  id                   :bigint(8)        not null, primary key
#  address              :string
#  customer             :boolean
#  description          :string
#  enabled              :boolean
#  error_string         :string
#  is_changed           :boolean
#  name                 :string
#  phones               :string
#  smtp_connection_name :string
#  vendor               :boolean
#  o_id                 :integer(4)
#  smtp_connection_id   :integer(4)
#
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
