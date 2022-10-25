# frozen_string_literal: true

class NotificationEvent
  class << self
    delegate :low_threshold_reached,
             :high_threshold_reached,
             :low_threshold_cleared,
             :high_threshold_cleared,
             :dialpeer_locked,
             :dialpeer_unlocked,
             :gateway_locked,
             :gateway_unlocked,
             :destination_quality_alarm_fired,
             :destination_quality_alarm_cleared,
             to: :new

    def event_time
      Time.current.strftime('%F %T %Z')
    end
  end

  def low_threshold_reached(account)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED,
      subject: "Account with id #{account.id} low balance",
      message: account_threshold_message(account),
      additional_contacts: account_contacts(account),
      event_data: account_threshold_data(account)
    )
  end

  def high_threshold_reached(account)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_REACHED,
      subject: "Account with id #{account.id} high balance",
      message: account_threshold_message(account),
      additional_contacts: account_contacts(account),
      event_data: account_threshold_data(account)
    )
  end

  def low_threshold_cleared(account)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_CLEARED,
      subject: "Account with id #{account.id} low balance cleared",
      message: account_threshold_message(account),
      additional_contacts: account_contacts(account),
      event_data: account_threshold_data(account)
    )
  end

  def high_threshold_cleared(account)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_CLEARED,
      subject: "Account with id #{account.id} high balance cleared",
      message: account_threshold_message(account),
      additional_contacts: account_contacts(account),
      event_data: account_threshold_data(account)
    )
  end

  def dialpeer_locked(dialpeer, quality_stat)
    message = [
      "ACD Limit: #{dialpeer.acd_limit}, ACD actual value: #{quality_stat.acd}",
      "ASR Limit: #{dialpeer.asr_limit}, ASR actual value: #{quality_stat.asr}"
    ].join("\n")
    fire_event(
      System::EventSubscription::CONST::EVENT_DIALPEER_LOCKED,
      subject: "Dialpeer with id #{dialpeer.id} locked by quality",
      message: message,
      event_data: dialpeer.attributes.merge(acd: quality_stat.acd, asr: quality_stat.asr)
    )
  end

  def dialpeer_unlocked(dialpeer)
    subject = "Dialpeer with id #{dialpeer.id} unlocked"
    fire_event(
      System::EventSubscription::CONST::EVENT_DIALPEER_UNLOCKED,
      subject: subject,
      message: subject,
      event_data: dialpeer.attributes
    )
  end

  def gateway_locked(gateway, quality_stat)
    message = [
      "ACD Limit: #{gateway.acd_limit}, ACD actual value: #{quality_stat.acd}",
      "ASR Limit: #{gateway.asr_limit}, ASR actual value: #{quality_stat.asr}"
    ].join("\n")
    fire_event(
      System::EventSubscription::CONST::EVENT_GATEWAY_LOCKED,
      subject: "Gateway with id #{gateway.id} locked by quality",
      message: message,
      event_data: gateway.attributes.merge(acd: quality_stat.acd, asr: quality_stat.asr)
    )
  end

  def gateway_unlocked(gateway)
    subject = "Gateway with id #{gateway.id} unlocked"
    fire_event(
      System::EventSubscription::CONST::EVENT_GATEWAY_UNLOCKED,
      subject: subject,
      message: subject,
      event_data: gateway.attributes
    )
  end

  def destination_quality_alarm_fired(destination, quality_stat)
    message = [
      "ACD Limit: #{destination.acd_limit}, ACD actual value: #{quality_stat.acd}",
      "ASR Limit: #{destination.asr_limit}, ASR actual value: #{quality_stat.asr}"
    ].join("\n")
    fire_event(
      System::EventSubscription::CONST::EVENT_DESTINATION_QUALITY_ALARM_FIRED,
      subject: "Destination with id #{destination.id} Quality alarm fired",
      message: message,
      additional_contacts: destination_contacts(destination),
      event_data: destination.attributes.merge(acd: quality_stat.acd, asr: quality_stat.asr)
    )
  end

  def destination_quality_alarm_cleared(destination)
    subject = "Destination with id #{destination.id} Quality alarm cleared"
    fire_event(
      System::EventSubscription::CONST::EVENT_DESTINATION_QUALITY_ALARM_CLEARED,
      subject: subject,
      message: subject,
      additional_contacts: destination_contacts(destination),
      event_data: destination.attributes
    )
  end

  private

  def account_threshold_message(account)
    data = account.attributes.merge(
      balance_low_threshold: account.balance_notification_setting.low_threshold,
      balance_high_threshold: account.balance_notification_setting.high_threshold,
      send_balance_notifications_to: account.balance_notification_setting.send_to
    )
    data.to_json
  end

  def account_threshold_data(account)
    account.attributes.merge(
      balance_low_threshold: account.balance_notification_setting.low_threshold,
      balance_high_threshold: account.balance_notification_setting.high_threshold,
      send_balance_notifications_to: account.balance_notification_setting.send_to
    )
  end

  def account_contacts(account)
    account.balance_notification_setting.contacts.preload(contractor: :smtp_connection).to_a
  end

  def destination_contacts(destination)
    contact_ids = destination.rateplans.pluck(:send_quality_alarms_to).flatten.compact.uniq
    Billing::Contact.where(id: contact_ids).preload(contractor: :smtp_connection).to_a
  end

  def fire_event(event, subject:, message:, additional_contacts: nil, event_data:)
    subscription = find_subscription(event)
    contacts = subscription_contacts(subscription) + Array.wrap(additional_contacts)
    return if subscription.url.blank? && contacts.empty?

    ApplicationRecord.transaction do
      send_http_event(subscription, event_data) if subscription.url.present?
      ContactEmailSender.batch_send_emails(contacts, subject: subject, message: message) unless contacts.empty?
    end
  end

  def find_subscription(event)
    raise ArgumentError, "invalid event #{event}" if System::EventSubscription::CONST::EVENTS.exclude?(event)

    System::EventSubscription.find_by!(event: event)
  end

  def subscription_contacts(subscription)
    subscription.contacts.preload(contractor: :smtp_connection).to_a
  end

  def send_http_event(subscription, event_data)
    body = JSON.generate(
      event_type: subscription.event,
      event_data: event_data,
      event_time: self.class.event_time
    )
    Worker::SendHttpJob.perform_later(subscription.url, HttpSender::CONTENT_TYPE_JSON, body)
  end
end
