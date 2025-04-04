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
      src_name_in
      src_prefix_in
      dst_prefix_in
      from_domain
      to_domain
      ruri_domain
      lega_disconnect_code
      lega_disconnect_reason
      auth_orig_ip
      auth_orig_port
      src_prefix_routing
      dst_prefix_routing
      destination_prefix
      destination_initial_interval
      destination_next_interval
      destination_initial_rate
      destination_next_rate
      destination_fee
      customer_price
      customer_duration
      orig_call_id
      local_tag
      lega_user_agent
      diversion_in
    ].freeze

    model_class 'CdrExport'
    model_attributes :filters, :time_format, :time_zone_name
    attr_accessor :account_id, :customer_id, :allowed_account_ids

    before_validation :apply_fields
    validate :validate_account
    validate :validate_filters
    validate :validate_time_zone_name
    validates :time_format, presence: true,
                            inclusion: {
                              in: CdrExport::ALLOWED_TIME_FORMATS,
                              message: "is not included in the list: #{CdrExport::ALLOWED_TIME_FORMATS.join(', ')}"
                            }

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
      hidden_fields = YetiConfig.customer_api_outgoing_cdr_hide_fields || []
      model.fields = FIELDS - hidden_fields
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

    def validate_time_zone_name
      return if time_zone_name.nil?

      errors.add(:time_zone_name, :invalid) unless Yeti::TimeZoneHelper.all.any? { |i| i.name == time_zone_name }
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
