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
  self.table_name = "notifications.contacts"
  has_paper_trail class_name: 'AuditLogItem'


  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id
  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id

  before_destroy do
    Report::CustomerTrafficScheduler.where("? = ANY(send_to)", self.id).each do |c|
      c.send_to = c.send_to.reject { |el| el == self.id }
      c.save!
    end
    Report::VendorTrafficScheduler.where("? = ANY(send_to)", self.id).each do |c|
      c.send_to = c.send_to.reject { |el| el == self.id }
      c.save!
    end
    Report::CustomCdrScheduler.where("? = ANY(send_to)", self.id).each do |c|
      c.send_to = c.send_to.reject { |el| el == self.id }
      c.save!
    end
    Report::IntervalCdrScheduler.where("? = ANY(send_to)", self.id).each do |c|
      c.send_to = c.send_to.reject { |el| el == self.id }
      c.save!
    end
    Notification::Alert.where("? = ANY(send_to)", self.id).each do |c|
      c.send_to = c.send_to.reject { |el| el == self.id }
      c.save!
    end
    Account.where("? = ANY(send_invoices_to)", self.id).each do |c|
      c.send_invoices_to = c.send_invoices_to.reject { |el| el == self.id }
      c.save!
    end
    Account.where("? = ANY(send_balance_notifications_to)", self.id).each do |c|
      c.send_balance_notifications_to = c.send_balance_notifications_to.reject { |el| el == self.id }
      c.save!
    end
    Rateplan.where("? = ANY(send_quality_alarms_to)", self.id).each do |c|
      c.send_quality_alarms_to = c.send_quality_alarms_to.reject { |el| el == self.id }
      c.save!
    end

  end

  def smtp_connection
    self.contractor.try!(:smtp_connection) || System::SmtpConnection.global
  end

  def display_name
    if self.contractor.present?
      "#{self.contractor.display_name} | #{self.email}"
    elsif self.admin_user.present?
      "#{self.admin_user.username} | #{self.email}"
    else
      "#{self.email}"
    end
  end

  def self.collection
    includes(:contractor, :admin_user).order(:email)
  end

end
