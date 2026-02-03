# frozen_string_literal: true

class Billing::Service::Renew
  Error = Class.new(StandardError)
  DESCRIPTION = 'Renew service'

  class << self
    def perform(service)
      new(service).perform
    end
  end

  attr_reader :service
  delegate :account, to: :service

  def initialize(service)
    @service = service
  end

  def perform
    return skip_terminated_service if service.terminated?

    service.transaction do
      account.lock! # will generate SELECT FOR UPDATE SQL statement
      service.lock!
      provisioning_object.before_renew

      if !enough_balance? && !service.type.force_renew
        service.update!(state_id: Billing::Service::STATE_ID_SUSPENDED)
        provisioning_object.after_failed_renew
        provisioning_object.after_renew
        Rails.logger.info { "Not enough balance to renew billing service ##{service.id}" }
        nil
      else
        service.update!(state_id: Billing::Service::STATE_ID_ACTIVE, renew_at: next_renew_at)
        create_transaction unless service.renew_price.zero?
        provisioning_object.after_success_renew
        provisioning_object.after_renew
        Rails.logger.info { "Success renew billing service ##{service.id}" }
      end
    end
  end

  private

  def create_transaction
    transaction = Billing::Transaction.new(
      service:,
      account:,
      amount: service.renew_price,
      description: DESCRIPTION
    )
    raise Error, "Failed to create transaction: #{transaction.errors.full_messages.to_sentence}" unless transaction.save

    transaction
  end

  def provisioning_object
    @provisioning_object ||= service.build_provisioning_object
  end

  def skip_terminated_service
    Rails.logger.info { "Skip renew billing service ##{service.id} because it is terminated" }
    nil
  end

  def next_renew_at
    if service.renew_period_id == Billing::Service::RENEW_PERIOD_ID_DAY
      Time.current.beginning_of_day + 1.day
    elsif service.renew_period_id == Billing::Service::RENEW_PERIOD_ID_MONTH
      Time.current.beginning_of_month + 1.month
    end
  end

  def enough_balance?
    if service.renew_price.positive?
      account.balance - service.renew_price >= account.min_balance
    elsif service.renew_price.negative?
      account.balance - service.renew_price <= account.max_balance
    else # service.renew_price.zero?
      true
    end
  end
end
