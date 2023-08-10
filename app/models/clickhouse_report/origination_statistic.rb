# frozen_string_literal: true

module ClickhouseReport
  class OriginationStatistic < Base
    SAMPLINGS = {
      'minute' => 'toStartOfMinute',
      '5minutes' => 'toStartOfFiveMinutes',
      'hour' => 'toStartOfHour',
      'day' => 'toStartOfDay',
      'week' => 'toStartOfWeek',
      'month' => 'toStartOfMonth'
    }.freeze

    filter 'account-id',
           column: :customer_acc_id,
           type: 'UInt32',
           operation: :eq,
           required: true,
           format_value: lambda { |value, opts|
             account = opts[:context][:customer].find_allowed_account(value)
             raise InvalidParamValue, 'invalid value account-id' if account.nil?

             account.id
           }

    filter :'from-time',
           column: :time_start,
           type: 'DateTime',
           operation: :gteq,
           required: true

    filter :'to-time',
           column: :time_start,
           type: 'DateTime',
           operation: :lteq

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

    filter :'auth-orig-ip',
           column: :auth_orig_ip,
           type: 'String',
           operation: :eq

    filter :'customer-price-eq',
           column: :customer_price,
           type: 'Float64',
           operation: :eq

    filter :'customer-price-gt',
           column: :customer_price,
           type: 'Float64',
           operation: :gt

    filter :'customer-price-lt',
           column: :customer_price,
           type: 'Float64',
           operation: :lt

    def self.required_params
      super() + [:sampling]
    end

    private

    def prepare_sql(filters)
      sampling_fn = SAMPLINGS.fetch(params[:sampling]) do
        raise InvalidParamValue, 'invalid sampling'
      end

      "
      SELECT
        toUnixTimestamp(#{sampling_fn}(time_start)) as t,
        toUInt32(count(*)) AS total_calls,
        toUInt32(countIf(duration>0)) as successful_calls,
        toUInt32(countIf(duration=0)) as failed_calls,
        round(sum(duration)/60,2) as total_duration,
        round(avgIf(duration, duration>0)/60,2) AS acd,
        round(countIf(duration>0)/count(*),3)*100 AS asr,
        round(sum(customer_price),2) as total_price
      FROM cdrs
      WHERE #{filters.values.join(' AND ')} AND is_last_cdr = true
      GROUP BY t
      WITH TOTALS
      ORDER BY t
      FORMAT JSONColumnsWithMetadata
      "
    end
  end
end
