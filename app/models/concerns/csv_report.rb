# frozen_string_literal: true

module CsvReport
  extend ActiveSupport::Concern

  included do
    attr_accessor :send_to

    validate do
      if send_to.present? && send_to.any?
        errors.add(:send_to, :invalid) if contacts.count != send_to.count
      end
    end

    def send_to=(send_to_ids)
      @send_to = send_to_ids.reject(&:blank?)
    end

    def contacts
      unless instance_variable_defined?(:@contacts)
        @contacts ||= Billing::Contact.where(id: send_to)
      end
      @contacts
    end
  end
end
