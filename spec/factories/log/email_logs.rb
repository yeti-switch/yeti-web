# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.email_logs
#
#  id                 :bigint(8)        not null, primary key
#  error              :string
#  mail_from          :string           not null
#  mail_to            :string           not null
#  msg                :string
#  sent_at            :timestamptz
#  subject            :string           not null
#  created_at         :timestamptz
#  attachment_id      :integer(4)       is an Array
#  batch_id           :bigint(8)
#  contact_id         :integer(4)
#  smtp_connection_id :integer(4)
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
