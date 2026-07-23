# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.notification_templates
# Database name: primary
#
#  id      :integer(4)       not null, primary key
#  body    :text             not null
#  event   :string           not null
#  subject :string           not null
#
# Indexes
#
#  notification_templates_event_key  (event) UNIQUE
#

# Admin-editable liquid templates for notification emails.
#
# Liquid is used rather than ERB on purpose: the body is edited through the admin
# UI and stored in the database, so the engine must not be able to execute
# arbitrary ruby. Templates can only reference the assigns built by
# BalanceNotificationMail.
class Billing::NotificationTemplate < ApplicationRecord
  self.table_name = 'billing.notification_templates'

  module CONST
    # Only balance notifications are template-driven for now. The authoritative
    # list lives in BalanceNotificationMail, which defines what it can render;
    # this points at it so the two cannot drift.
    EVENTS = BalanceNotificationMail::EVENTS

    freeze
  end

  include WithPaperTrail

  validates :event, :subject, :body, presence: true
  validates :event, uniqueness: true, inclusion: { in: CONST::EVENTS }
  validate :validate_liquid_syntax

  # One row per event is seeded by migration and by db/seeds/main/billing.sql, and
  # must exist for the lifetime of the install: it is the only source of the
  # email. Admins edit them; they never create or destroy them.
  before_destroy { throw :abort }

  def display_name
    "#{event} | #{id}"
  end

  # Rendered leniently: an unknown variable yields an empty string rather than
  # raising. Typos are caught at save time by #validate_liquid_syntax instead.
  # There is no fallback template, so this matters: a render that raised here
  # would abort the every-minute Jobs::AccountBalanceNotify run.
  def render_subject(assigns)
    parse(subject).render!(assigns.deep_stringify_keys)
  end

  def render_body(assigns)
    parse(body).render!(assigns.deep_stringify_keys)
  end

  private

  def parse(source)
    Liquid::Template.parse(source, error_mode: :strict)
  end

  # Catches both syntax errors and references to variables that will never be
  # supplied, by rendering against a sample in strict_variables mode.
  def validate_liquid_syntax
    sample = BalanceNotificationMail.sample_assigns.deep_stringify_keys

    { subject: subject, body: body }.each do |attribute, source|
      next if source.blank?

      begin
        parse(source).render!(sample, strict_variables: true)
      rescue Liquid::SyntaxError => e
        errors.add(attribute, "liquid syntax error: #{e.message}")
      rescue Liquid::UndefinedVariable => e
        errors.add(attribute, "unknown variable: #{e.message}")
      rescue Liquid::Error => e
        errors.add(attribute, "liquid error: #{e.message}")
      end
    end
  end
end
