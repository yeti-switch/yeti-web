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
  end

  def low_threshold_reached(account, data)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED,
      subject: "Account with id #{account.id} low balance",
      message: data.to_s,
      additional_contacts: account_contacts(account)
    )
  end

  def high_threshold_reached(account, data)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_REACHED,
      subject: "Account with id #{account.id} high balance",
      message: data.to_s,
      additional_contacts: account_contacts(account)
    )
  end

  def low_threshold_cleared(account, data)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_CLEARED,
      subject: "Account with id #{account.id} low balance cleared",
      message: data.to_s,
      additional_contacts: account_contacts(account)
    )
  end

  def high_threshold_cleared(account, data)
    fire_event(
      System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_CLEARED,
      subject: "Account with id #{account.id} high balance cleared",
      message: data.to_s,
      additional_contacts: account_contacts(account)
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
      message: message
    )
  end

  def dialpeer_unlocked(dialpeer)
    subject = "Dialpeer with id #{dialpeer.id} unlocked"
    fire_event(
      System::EventSubscription::CONST::EVENT_DIALPEER_UNLOCKED,
      subject: subject,
      message: subject
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
      message: message
    )
  end

  def gateway_unlocked(gateway)
    subject = "Gateway with id #{gateway.id} unlocked"
    fire_event(
      System::EventSubscription::CONST::EVENT_GATEWAY_UNLOCKED,
      subject: subject,
      message: subject
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
      additional_contacts: destination_contacts(destination)
    )
  end

  def destination_quality_alarm_cleared(destination)
    subject = "Destination with id #{destination.id} Quality alarm cleared"
    fire_event(
      System::EventSubscription::CONST::EVENT_DESTINATION_QUALITY_ALARM_CLEARED,
      subject: subject,
      message: subject,
      additional_contacts: destination_contacts(destination)
    )
  end

  private

  def account_contacts(account)
    account.contacts_for_balance_notifications.preload(contractor: :smtp_connection).to_a
  end

  def destination_contacts(destination)
    contact_ids = destination.rateplans.pluck(:send_quality_alarms_to).flatten.compact.uniq
    Billing::Contact.where(id: contact_ids).preload(contractor: :smtp_connection).to_a
  end

  def fire_event(event, subject:, message:, additional_contacts: nil)
    subscription = find_subscription(event)
    contacts = subscription_contacts(subscription) + Array.wrap(additional_contacts)
    return if contacts.empty?

    ContactEmailSender.batch_send_emails(contacts, subject: subject, message: message)
  end

  def find_subscription(event)
    raise ArgumentError, "invalid event #{event}" if System::EventSubscription::CONST::EVENTS.exclude?(event)

    System::EventSubscription.find_by!(event: event)
  end

  def subscription_contacts(subscription)
    subscription.contacts.preload(contractor: :smtp_connection).to_a
  end
end
