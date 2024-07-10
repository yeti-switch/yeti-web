# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routeset_discriminators
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routeset_discriminators_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :routeset_discriminator, class: Routing::RoutesetDiscriminator do
    sequence(:name) { |n| "Discriminator #{n}" }
  end
end
