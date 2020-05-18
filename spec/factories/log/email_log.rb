# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.email_logs
#
#  id                 :integer          not null, primary key
#  batch_id           :integer
#  created_at         :datetime
#  sent_at            :datetime
#  contact_id         :integer
#  smtp_connection_id :integer
#  mail_to            :string           not null
#  mail_from          :string           not null
#  subject            :string           not null
#  msg                :string
#  error              :string
#  attachment_id      :integer          is an Array
#

FactoryBot.define do
  factory :email_log, class: Log::EmailLog do
    sent_at { Time.now.utc }
    contact
    smtp_connection
    mail_to { 'demo@demo.ua' }
    mail_from { 'demo@admin.ua' }
    subject { 'Check email' }
  end
end
