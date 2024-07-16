# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.tag_actions
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  tag_actions_name_key  (name) UNIQUE
#

FactoryBot.define do
  factory :tag_action, class: 'Routing::TagAction' do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Clear tags #{n}" }
  end
end
