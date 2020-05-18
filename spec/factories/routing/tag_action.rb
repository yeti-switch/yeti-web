# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.tag_actions
#
#  id   :integer          not null, primary key
#  name :string           not null
#

FactoryBot.define do
  factory :tag_action, class: Routing::TagAction do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Clear tags #{n}" }
  end
end
