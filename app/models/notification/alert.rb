# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.alerts
#
#  id      :integer          not null, primary key
#  event   :string           not null
#  send_to :integer          is an Array
#

class Notification::Alert < Yeti::ActiveRecord
  self.table_name = 'notifications.alerts'

  has_paper_trail class_name: 'AuditLogItem'

  include Hints

  validate do
    if send_to.present? && send_to.any?
      errors.add(:send_to, :invalid) if contacts.count != send_to.count
    end
  end

  def contacts
    @contacts ||= Billing::Contact.where(id: send_to)
  end

  def send_to=(send_to_ids)
    self[:send_to] = send_to_ids.reject(&:blank?)
  end

  def display_name
    "#{event} | #{id}"
  end

  def self.fire_account_low_balance(account, data)
    event_name = 'AccountLowThesholdReached'
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{account.class} with id #{account.id} low balance",
      data.to_s,
      account.contacts_for_balance_notifications
    )
  end

  def self.fire_account_high_balance(account, data)
    event_name = 'AccountHighThesholdReached'
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{account.class} with id #{account.id} high balance",
      data.to_s,
      account.contacts_for_balance_notifications
    )
  end

  def self.clear_account_low_balance(account, data)
    event_name = 'AccountLowThesholdCleared'
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{account.class} with id #{account.id} low balance cleared",
      data.to_s,
      account.contacts_for_balance_notifications
    )
  end

  def self.clear_account_high_balance(account, data)
    event_name = 'AccountHighThesholdCleader'
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{account.class} with id #{account.id} high balance cleared",
      data.to_s,
      account.contacts_for_balance_notifications
    )
  end

  def self.fire_quality_alarm(dst, stats)
    event_name = "#{dst.class}QualityAlarmFired"
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{dst.class} with id #{dst.id} Quality alarm fired",
      "ACD Limit: #{dst.acd_limit}, ACD actual value: #{stats.acd}\n
       ASR Limit: #{dst.asr_limit}, ASR actual value: #{stats.asr}",
      dst.rateplan.contacts
    )
  end

  def self.clear_quality_alarm(dst)
    event_name = "#{dst.class}QualityAlarmCleared"
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{dst.class} with id #{dst.id} Quality alarm cleared",
      "#{dst.class} with id #{dst.id} Quality alarm cleared",
      dst.rateplan.contacts
    )
  end

  def self.fire_lock(dp_or_gw, stats)
    event_name = "#{dp_or_gw.class}Locked"
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{dp_or_gw.class} with id #{dp_or_gw.id} locked by quality",
      "ACD Limit: #{dp_or_gw.acd_limit}, ACD actual value: #{stats.acd}\n
       ASR Limit: #{dp_or_gw.asr_limit}, ASR actual value: #{stats.asr}"
    )
  end

  def self.fire_unlock(dp_or_gw)
    event_name = "#{dp_or_gw.class}Unlocked"
    a = Notification::Alert.find_by(event: event_name)
    return if a.nil?

    a.fire_event(
      "#{dp_or_gw.class} with id #{dp_or_gw.id} unlocked",
      "#{dp_or_gw.class} with id #{dp_or_gw.id} unlocked"
    )
  end

  def fire_event(subj, msg, additional_contacts = nil)
    @contact_list = contacts
    @contact_list += additional_contacts unless additional_contacts.nil?
    if @contact_list.any?
      @contact_list.each do |contact|
        Log::EmailLog.create!(
          contact_id: contact.id,
          smtp_connection_id: contact.smtp_connection.id,
          mail_to: contact.email,
          mail_from: contact.smtp_connection.from_address,
          subject: subj,
          msg: msg
        )
      end
    end
  end
end
