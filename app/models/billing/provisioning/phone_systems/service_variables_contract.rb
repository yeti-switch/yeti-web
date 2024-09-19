# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class ServiceVariablesContract < Dry::Validation::Contract
        json(ServiceVariablesSchema)
      end
    end
  end
end
