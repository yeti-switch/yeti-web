# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.attachments
#
#  id       :integer(4)       not null, primary key
#  data     :binary
#  filename :string           not null
#

FactoryBot.define do
  factory :notification_attachment, class: 'Notification::Attachment' do
    sequence(:filename) { |n| "some_file#{n}.txt" }
    sequence(:data) { |n| "some data #{n}" }
  end
end
