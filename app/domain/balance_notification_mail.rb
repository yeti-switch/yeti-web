# frozen_string_literal: true

# Builds the subject and HTML body of an account balance notification email from
# the admin-editable template stored in billing.notification_templates.
#
# The database is the only source: there is no packaged fallback. A row is
# guaranteed to exist for every event by the create_notification_templates
# migration and by db/seeds/main/billing.sql, and Billing::NotificationTemplate
# refuses to be destroyed, so a missing row means a broken install and is raised
# rather than papered over.
#
# The assigns exposed here are the *whole* contract available to a template.
# Nothing else about the account is reachable, which is deliberate: this used to
# send account.attributes.to_json, leaking every column of billing.accounts (and
# the other recipients' addresses) to every contact.
class BalanceNotificationMail
  EVENTS = [
    System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_REACHED,
    System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_REACHED,
    System::EventSubscription::CONST::EVENT_ACCOUNT_LOW_THRESHOLD_CLEARED,
    System::EventSubscription::CONST::EVENT_ACCOUNT_HIGH_THRESHOLD_CLEARED
  ].freeze

  class << self
    # Used by Billing::NotificationTemplate to validate templates at save time,
    # and by the admin preview action.
    def sample_assigns
      {
        account: { id: 123, name: 'Sample account', balance: '42.00', currency: 'EUR' },
        threshold: { low: '100.00', high: '10000.00' },
        event: { type: EVENTS.first, time: NotificationEvent.event_time }
      }
    end

    # Flattened view of the assigns contract, shown in the admin UI. Derived from
    # sample_assigns so the documentation cannot drift from what is exposed.
    def variable_reference
      sample_assigns.flat_map do |group, values|
        values.map { |key, value| { name: "#{group}.#{key}", example: value.to_s } }
      end
    end
  end

  # @param account [Account]
  # @param event [String] one of System::EventSubscription::CONST balance events
  def initialize(account, event)
    raise ArgumentError, "invalid event #{event}" unless EVENTS.include?(event)

    @account = account
    @event = event
  end

  # @raise [ActiveRecord::RecordNotFound] when the seeded row is missing
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
