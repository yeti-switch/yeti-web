# frozen_string_literal: true

class Billing::Service::Renew
  Error = Class.new(StandardError)
  DESCRIPTION = 'Renew service'

  attr_reader :service
  delegate :account, to: :service

  def initialize(service)
    @service = service
  end

  def perform
    service.transaction do
      account.lock! # will generate SELECT FOR UPDATE SQL statement
      provisioning_object.before_renew

      if !enough_balance? && !service.type.force_renew
        service.update!(state_id: Billing::Service::STATE_ID_SUSPENDED)
        provisioning_object.after_failed_renew
        provisioning_object.after_renew
        return
      end

      service.update!(
        state_id: Billing::Service::STATE_ID_ACTIVE,
        renew_at: next_renew_at
      )

      transaction = Billing::Transaction.new(
        service:,
        account:,
        amount: service.renew_price,
        description: DESCRIPTION
      )
      raise Error, "Failed to create transaction: #{transaction.errors.full_messages.to_sentence}" unless transaction.save

      provisioning_object.after_success_renew
      provisioning_object.after_renew
      transaction
    end
  end

  private

  def provisioning_object
    @provisioning_object ||= service.type.provisioning_class.constantize.new(service)
  end

  def next_renew_at
    if service.renew_period_id == Billing::Service::RENEW_PERIOD_ID_DAY
      Time.current.beginning_of_day + 1.day
    elsif service.renew_period_id == Billing::Service::RENEW_PERIOD_ID_MONTH
      Time.current.beginning_of_month + 1.month
    end
  end

  def enough_balance?
    account.balance - account.min_balance >= service.renew_price
  end
end
