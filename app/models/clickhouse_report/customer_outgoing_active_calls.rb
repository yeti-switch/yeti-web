# frozen_string_literal: true

module ClickhouseReport
  class CustomerOutgoingActiveCalls < Base
    COLUMNS = %i[
      snapshot_timestamp
      start_time
      connect_time
      destination_prefix
      destination_initial_interval
      destination_initial_rate
      destination_next_interval
      destination_next_rate
      destination_fee
      src_name_in
      src_prefix_in
      dst_prefix_in
      src_prefix_routing
      dst_prefix_routing
      from_domain
      to_domain
      ruri_domain
      diversion_in
      pai_in
      ppi_in
      privacy_in
      rpid_in
      rpid_privacy_in
      auth_orig_transport_protocol_id
      auth_orig_ip
      auth_orig_port
    ].freeze

    filter :'account-id',
           column: :customer_acc_id,
           type: 'Int32',
           operation: :eq,
           required: true,
           format_value: lambda { |value, opts|
             account = opts[:context][:auth_context].find_allowed_account(value)
             raise InvalidParamValue, 'invalid value account-id' if account.nil?

             account.id
           }

    filter :'auth-orig-ip',
           column: :auth_orig_ip,
           type: 'String',
           operation: :eq

    filter :'auth-orig-port',
           column: :auth_orig_port,
           type: 'Int32',
           operation: :eq

    filter :'auth-orig-transport-protocol-id',
           column: :auth_orig_transport_protocol_id,
           type: 'Int8',
           operation: :eq

    filter :'connect-time-null',
           column: :connect_time,
           type: 'DateTime',
           operation: :null

    %w[eq starts_with ends_with contains].each do |op|
      filter :"src-name-in-#{op.dasherize}",
             column: :src_name_in,
             type: 'String',
             operation: op.to_sym

      filter :"src-prefix-in-#{op.dasherize}",
             column: :src_prefix_in,
             type: 'String',
             operation: op.to_sym

      filter :"dst-prefix-in-#{op.dasherize}",
             column: :dst_prefix_in,
             type: 'String',
             operation: op.to_sym

      filter :"src-prefix-routing-#{op.dasherize}",
             column: :src_prefix_routing,
             type: 'String',
             operation: op.to_sym

      filter :"dst-prefix-routing-#{op.dasherize}",
             column: :dst_prefix_routing,
             type: 'String',
             operation: op.to_sym
    end

    private

    def prepare_context_filters
      [
        { customer_id: 'customer_id = {customer_id: Int32}' },
        { param_customer_id: context[:auth_context].customer_id }
      ]
    end

    def prepare_sql(filters)
      "
      SELECT
        #{COLUMNS.map(&:to_s).join(', ')}
      FROM active_calls
      WHERE snapshot_timestamp = (select max(snapshot_timestamp) from active_calls)
        AND #{filters.values.join(' AND ')}
      ORDER BY start_time DESC
      FORMAT JSON
      "
    end
  end
end
