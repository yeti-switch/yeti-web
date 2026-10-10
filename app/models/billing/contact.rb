# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.contacts
# Database name: primary
#
#  id            :integer(4)       not null, primary key
#  email         :string           not null
#  notes         :string
#  created_at    :timestamptz
#  updated_at    :timestamptz
#  admin_user_id :integer(4)
#  contractor_id :integer(4)
#
# Indexes
#
#  contacts_contractor_id_idx  (contractor_id)
#
# Foreign Keys
#
#  contacts_admin_user_id_fkey  (admin_user_id => admin_users.id)
#  contacts_contractor_id_fkey  (contractor_id => contractors.id)
#

class Billing::Contact < ApplicationRecord
  self.table_name = 'notifications.contacts'
  include WithPaperTrail

  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id, optional: true
  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id, optional: true

  scope :contractors, -> { where.not(contractor_id: nil) }

  validates :email, presence: true, format: { with: EMAIL_FORMAT, allow_blank: true }

  after_destroy_commit do
    [
      Report::CustomerTrafficScheduler,
      Report::VendorTrafficScheduler,
      Report::CustomCdrScheduler,
      Report::IntervalCdrScheduler
    ].each do |scheduler_class|
      scheduler_class.where('? = ANY(send_to)', id).update_all(['send_to = array_remove(send_to, ?)', id])
    end
  end

  before_destroy do
    System::EventSubscription.where('? = ANY(send_to)', id).find_each do |c|
      c.send_to = c.send_to.reject { |el| el == id }
      c.save!
    end
    Account.where('? = ANY(send_invoices_to)', id).find_each do |c|
      c.send_invoices_to = c.send_invoices_to.reject { |el| el == id }
      c.save!
    end
    AccountBalanceNotificationSetting.where('? = ANY(send_to)', id).find_each do |c|
      c.send_to = c.send_to.reject { |el| el == id }
      c.save!
    end
    Routing::Rateplan.where('? = ANY(send_quality_alarms_to)', id).find_each do |c|
      c.send_quality_alarms_to = c.send_quality_alarms_to.reject { |el| el == id }
      c.save!
    end
  end

  def smtp_connection
    contractor&.smtp_connection || System::SmtpConnection.global
  end

  def display_name
    if contractor.present?
      "#{contractor.display_name} | #{email}"
    elsif admin_user.present?
      "#{admin_user.username} | #{email}"
    else
      email.to_s
    end
  end

  def self.collection
    includes(:contractor, :admin_user).order(:email)
  end
end
