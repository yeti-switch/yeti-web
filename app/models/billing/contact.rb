# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.contacts
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  admin_user_id :integer
#  email         :string           not null
#  notes         :string
#  created_at    :datetime
#  updated_at    :datetime
#

class Billing::Contact < Yeti::ActiveRecord
  self.table_name = 'notifications.contacts'
  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id
  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id

  scope :contractors, -> { where.not(contractor_id: nil) }

  before_destroy do
    Report::CustomerTrafficScheduler.where('? = ANY(send_to)', id).find_each do |c|
      c.send_to = c.send_to.reject { |el| el == id }
      c.save!
    end
    Report::VendorTrafficScheduler.where('? = ANY(send_to)', id).find_each do |c|
      c.send_to = c.send_to.reject { |el| el == id }
      c.save!
    end
    Report::CustomCdrScheduler.where('? = ANY(send_to)', id).find_each do |c|
      c.send_to = c.send_to.reject { |el| el == id }
      c.save!
    end
    Report::IntervalCdrScheduler.where('? = ANY(send_to)', id).find_each do |c|
      c.send_to = c.send_to.reject { |el| el == id }
      c.save!
    end
    Notification::Alert.where('? = ANY(send_to)', id).find_each do |c|
      c.send_to = c.send_to.reject { |el| el == id }
      c.save!
    end
    Account.where('? = ANY(send_invoices_to)', id).find_each do |c|
      c.send_invoices_to = c.send_invoices_to.reject { |el| el == id }
      c.save!
    end
    Account.where('? = ANY(send_balance_notifications_to)', id).find_each do |c|
      c.send_balance_notifications_to = c.send_balance_notifications_to.reject { |el| el == id }
      c.save!
    end
    Rateplan.where('? = ANY(send_quality_alarms_to)', id).find_each do |c|
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
