# frozen_string_literal: true

class PhoneSystemsSessionForm < ApplicationForm
  attr_reader :uuid
  attr_accessor :customer
  attr_accessor :api_access

  attribute :service
  attribute :phone_systems_url

  def persisted?
    false
  end

  validate do
    errors.add(:base, 'service not found') if service_relation.nil? || customer_id_from_current_service != customer_id_from_session

    if service_relation && api_access.account_ids.any? && api_access.account_ids.exclude?(service_relation.account_id)
      errors.add(:service, 'Account of current Service is not related to current API Access')
    end
  end

  private

  def _save
    self.phone_systems_url = Billing::Provisioning::PhoneSystems::SessionCreationService.call!(service_relation)

    @uuid = SecureRandom.uuid
  rescue Billing::Provisioning::Errors::Error => e
    errors.add(:base, 'failed to create Phone Systems session')
  end

  def service_relation
    Billing::Service.find_by(uuid: service)
  end

  def customer_id_from_current_service
    return if service_relation.nil?

    service_relation.account.contractor_id
  end

  def customer_id_from_session
    customer.id
  end
end
