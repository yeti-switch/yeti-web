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
  include LiquidTemplate

  validates :event, :subject, :body, presence: true
  validates :event, uniqueness: true, inclusion: { in: CONST::EVENTS }
  validates_liquid_syntax :subject, :body, sample: -> { BalanceNotificationMail.sample_assigns }

  before_destroy { throw :abort }

  def display_name
    "#{event} | #{id}"
  end

  def render_subject(assigns)
    render_liquid(subject, assigns)
  end

  def render_body(assigns)
    render_liquid(body, assigns)
  end
end
