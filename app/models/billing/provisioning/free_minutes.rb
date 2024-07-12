# frozen_string_literal: true

module Billing
  module Provisioning
    # Accepts Service Type variables in format:
    # {
    #   "prefixes": [
    #     {
    #      "prefix": "123",
    #      "duration": 60,
    #      "exclude": false
    #     },
    #     ...
    #   ]
    # }
    # Accepts Service variables in format:
    # {
    #   "prefixes": [
    #     {
    #      "prefix": "456",
    #      "duration": 60,
    #      "exclude": false
    #     },
    #     ...
    #   ],
    #   "ignore_prefixes": ["123", ...]
    # }
    # "exclude" is optional and defaults to false
    # "ignore_prefixes" is optional and defaults to []
    #
    class FreeMinutes < Base
      PrefixSchema = Dry::Schema.JSON do
        required(:prefix).filled(:string)
        required(:duration).value(:integer)
        optional(:exclude).maybe(:bool)
      end

      class ServiceTypeVariablesContract < Dry::Validation::Contract
        json do
          optional(:prefixes).array(PrefixSchema).default([])
        end
      end

      class ServiceVariablesContract < Dry::Validation::Contract
        json do
          optional(:prefixes).array(PrefixSchema).default([])
          optional(:ignore_prefixes).array(:string).default([])
        end
      end

      class << self
        def verify_service_type_variables!(service_type)
          contract = ServiceTypeVariablesContract.new
          result = contract.call(service_type.variables || {})
          raise Billing::Provisioning::Errors::InvalidVariablesError, result.errors.to_h unless result.success?

          result.to_h
        end
      end

      def verify_service_variables!
        contract = ServiceVariablesContract.new
        result = contract.call(service.variables || {})
        raise Billing::Provisioning::Errors::InvalidVariablesError, result.errors.to_h unless result.success?

        result.to_h
      end

      def after_create
        prefixes_data.each do |data|
          create_or_reset_counter(data)
        end
      end

      def after_success_renew
        prefixes_data.each do |data|
          create_or_reset_counter(data)
        end
        destroy_obsolete_counters
      end

      def before_destroy
        nil
      end

      private

      # if counter for prefix does not exist - will created it.
      # if counter for prefix exists - will reset duration and exclude.
      def create_or_reset_counter(data)
        counter = Billing::PackageCounter.find_or_initialize_by(account:, service:, prefix: data['prefix'])
        counter.assign_attributes(
          duration: data['duration'],
          exclude: data['exclude']
        )
        counter.save!
      end

      def destroy_obsolete_counters
        Billing::PackageCounter.where(service:).where.not(prefix: prefixes).find_each(&:destroy!)
      end

      def prefixes
        prefixes_data.map { |data| data['prefix'] }
      end

      def prefixes_data
        @prefixes_data ||= build_prefixes_data
      end

      def build_prefixes_data
        # service may override some service.type prefixes
        service_prefixes = service.variables['prefixes']
        service_type_prefixes = service.type.variables['prefixes']
        ignore_type_prefixes = service_prefixes.map { |data| data['prefix'] }
        # service may ignore some service.type prefixes
        ignore_type_prefixes += service.variables['ignore_prefixes']

        data_list = []
        service_type_prefixes.each do |data|
          next if ignore_type_prefixes.include? data['prefix']

          data_list << data
        end
        service_prefixes.each do |data|
          data_list << data
        end
        data_list.map do |data|
          data['exclude'] = false if data['exclude'].nil?
          data
        end
      end
    end
  end
end
