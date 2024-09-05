# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class ServiceTypeVariablesContract < Dry::Validation::Contract
        json(ServiceTypeSchema)
      end
    end
  end
end
