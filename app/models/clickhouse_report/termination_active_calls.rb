# frozen_string_literal: true

module ClickhouseReport
  class TerminationActiveCalls < Base
    filter 'account-id',
           column: :vendor_acc_id,
           type: 'UInt32',
           operation: :eq,
           required: true,
           format_value: lambda { |value, opts|
             account = opts[:context][:auth_context].find_allowed_account(value)
             raise InvalidParamValue, 'invalid value account-id' if account.nil?

             account.id
           }

    filter :'from-time',
           column: :snapshot_timestamp,
           type: 'DateTime',
           operation: :gteq,
           required: true,
           format_value: lambda { |value, _options|
             from_time = DateUtilities.safe_datetime_parse(value)
             raise InvalidParamValue, 'invalid value from-time' if from_time.nil?
             raise FromDateTimeInFutureError, 'from-time cannot be in the future' if from_time > DateTime.now

             value
           }

    filter :'to-time',
           column: :snapshot_timestamp,
           type: 'DateTime',
           operation: :lteq,
           format_value: lambda { |value, _options|
             to_time = DateUtilities.safe_datetime_parse(value)
             raise InvalidParamValue, 'invalid value to-time' if to_time.nil?

             value
           }

    filter :'src-country-id',
           column: :src_country_id,
           type: 'UInt32',
           operation: :eq

    filter :'dst-country-id',
           column: :dst_country_id,
           type: 'UInt32',
           operation: :eq

    filter :'src-prefix-routing-eq',
           column: :src_prefix_routing,
           type: 'String',
           operation: :eq

    filter :'src-prefix-routing-starts-with',
           column: :src_prefix_routing,
           type: 'String',
           operation: :starts_with

    filter :'src-prefix-routing-ends-with',
           column: :src_prefix_routing,
           type: 'String',
           operation: :ends_with

    filter :'src-prefix-routing-contains',
           column: :src_prefix_routing,
           type: 'String',
           operation: :contains

    filter :'dst-prefix-routing-eq',
           column: :dst_prefix_routing,
           type: 'String',
           operation: :eq

    filter :'dst-prefix-routing-starts-with',
           column: :dst_prefix_routing,
           type: 'String',
           operation: :starts_with

    filter :'dst-prefix-routing-ends-with',
           column: :dst_prefix_routing,
           type: 'String',
           operation: :ends_with

    filter :'dst-prefix-routing-contains',
           column: :dst_prefix_routing,
           type: 'String',
           operation: :contains

    filter :'duration-eq',
           column: :duration,
           type: 'Int32',
           operation: :eq

    filter :'duration-gt',
           column: :duration,
           type: 'Int32',
           operation: :gt

    filter :'duration-lt',
           column: :duration,
           type: 'Int32',
           operation: :lt

    filter :'vendor-price-eq',
           column: :vendor_price,
           type: 'Float64',
           operation: :eq

    filter :'vendor-price-gt',
           column: :vendor_price,
           type: 'Float64',
           operation: :gt

    filter :'vendor-price-lt',
           column: :vendor_price,
           type: 'Float64',
           operation: :lt

    def self.required_params
      super()
    end

    private

    def prepare_sql(filters)
      "
      SELECT
        toUnixTimestamp(snapshot_timestamp) as t,
        toUInt32(count(*)) AS calls
      FROM active_calls
      WHERE #{filters.values.join(' AND ')}
      GROUP BY t
      ORDER BY t
      WITH FILL FROM toUnixTimestamp(toStartOfMinute({from_time: DateTime})) TO toUnixTimestamp(now()) STEP 60
      FORMAT JSONColumnsWithMetadata
      "
    end
  end
end
