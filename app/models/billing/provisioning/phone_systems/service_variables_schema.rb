# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      ServiceVariablesSchema = Dry::Schema.JSON do
        optional(:endpoint).filled(:string)
        optional(:username).filled(:string)
        optional(:password).filled(:string)

        required(:attributes).filled(:hash).schema do
          required(:name).filled(:string)
          optional(:language).filled(:string)
          optional(:trm_mode).filled(:string)
          optional(:capacity_limit).value(:integer)
          optional(:sip_account_limit).value(:integer)
        end
      end
    end
  end
end
