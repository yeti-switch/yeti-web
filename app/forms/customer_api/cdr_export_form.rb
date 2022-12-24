# frozen_string_literal: true

module CustomerApi
  class CdrExportForm < ProxyForm
    def self.policy_class
      CdrExportPolicy
    end

    REQUIRED_FILTERS = %w[time_start_gteq time_start_lt].freeze
    OPTIONAL_FILTERS = %w[
      success_eq
      duration_eq
      duration_gteq
      duration_lteq
      src_prefix_routing_eq
      dst_prefix_routing_eq
    ].freeze
    ALLOWED_FILTERS = [*REQUIRED_FILTERS, *OPTIONAL_FILTERS].freeze
    FIELDS = %w[
      time_start
      time_connect
      time_end
      success
      duration
      src_prefix_routing
      dst_prefix_routing
      destination_initial_rate
      destination_next_rate
    ].freeze

    model_class 'CdrExport'
    model_attributes :filters
    attr_accessor :account_id, :customer_id, :allowed_account_ids

    before_validation :apply_fields
    validate :validate_account
    validate :validate_filters

    before_save :assign_customer_account
    after_create { model.reload } # need to get uuid from database

    define_memoizable :account, apply: lambda {
      return if account_id.blank?

      scope = Account.where(contractor_id: customer_id)
      scope = scope.where(id: allowed_account_ids) if allowed_account_ids.present?
      scope.find_by(uuid: account_id)
    }

    private

    def apply_fields
      model.fields = FIELDS
    end

    def validate_account
      errors.add(:account, :blank) if account_id.blank?
      errors.add(:account, :invalid) if account_id.present? && account.nil?
    end

    def validate_filters
      keys = filters&.as_json&.keys || []
      not_allowed_keys = keys - ALLOWED_FILTERS
      errors.add(:filters, "#{not_allowed_keys.join(', ')} not allowed") unless not_allowed_keys.empty?
    end

    def assign_customer_account
      model.customer_account = account
      model.filters.customer_acc_id_eq = account&.id
    end

    def transform_model_error(attribute, message)
      if attribute == :filters && message == 'requires time_start_lteq'
        [attribute, 'requires time_start_lt']
      elsif %i[customer_account customer_account_id].include?(attribute)
        [:account, message]
      else
        super
      end
    end
  end
end
