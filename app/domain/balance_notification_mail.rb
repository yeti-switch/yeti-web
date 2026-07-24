# frozen_string_literal: true

class BalanceNotificationMail
  EVENTS = [
    System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED,
    System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_REACHED,
    System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_CLEARED,
    System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_CLEARED
  ].freeze

  class << self
    def sample_assigns
      {
        account: { id: 123, name: 'Sample account', balance: '42.00', currency: 'EUR' },
        threshold: { low: '100.00', high: '10000.00' },
        event: { type: EVENTS.first, time: NotificationEvent.event_time }
      }
    end

    def variable_reference
      sample_assigns.flat_map do |group, values|
        values.map { |key, value| { name: "#{group}.#{key}", example: value.to_s } }
      end
    end
  end

  def initialize(account, event)
    raise ArgumentError, "invalid event #{event}" unless EVENTS.include?(event)

    @account = account
    @event = event
  end

  def template
    @template ||= Billing::NotificationTemplate.find_by!(event: event)
  end

  def subject
    template.render_subject(assigns)
  end

  def body
    template.render_body(assigns)
  end

  def assigns
    @assigns ||= {
      account: {
        id: account.id,
        name: account.name,
        balance: format_amount(account.balance),
        currency: account.currency_name
      },
      threshold: {
        low: format_amount(setting&.low_threshold),
        high: format_amount(setting&.high_threshold)
      },
      event: {
        type: event,
        time: NotificationEvent.event_time
      }
    }
  end

  private

  attr_reader :account, :event

  def setting
    account.balance_notification_setting
  end

  def format_amount(value)
    return nil if value.nil?

    format('%.2f', value)
  end
end
