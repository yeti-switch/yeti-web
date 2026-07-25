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

class Billing::NotificationTemplate < ApplicationRecord
  self.table_name = 'billing.notification_templates'

  module CONST
    EVENTS = BalanceNotificationMail::EVENTS

    freeze
  end

  include WithPaperTrail

  validates :event, :subject, :body, presence: true
  validates :event, uniqueness: true, inclusion: { in: CONST::EVENTS }
  validate :validate_liquid_syntax

  before_destroy { throw :abort }

  def display_name
    "#{event} | #{id}"
  end

  def render_subject(assigns)
    render_template(subject, assigns)
  end

  def render_body(assigns)
    render_template(body, assigns)
  end

  private

  def render_template(source, assigns)
    template = parse(source)
    output = template.render(assigns.deep_stringify_keys, strict_variables: true)
    if template.errors.any?
      Rails.logger.warn { "Billing::NotificationTemplate##{id} render: #{template.errors.map(&:message).join('; ')}" }
    end
    output
  end

  def parse(source)
    (@parsed ||= {})[source] ||= Liquid::Template.parse(source, error_mode: :strict)
  end

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
