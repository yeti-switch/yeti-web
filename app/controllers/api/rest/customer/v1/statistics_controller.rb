# frozen_string_literal: true

class Api::Rest::Customer::V1::StatisticsController < Api::RestController
  include CustomerV1Authorizable
  include ActionController::Cookies

  before_action :authorize!
  after_action :setup_authorization_cookie

  SAMPLINGS = {
    'minute' => 'toStartOfMinute',
    '5minutes' => 'toStartOfMinute5minutes',
    'hour' => 'toStartOfHour',
    'day' => 'toStartOfDay',
    'week' => 'toStartOfWeek',
    'month' => 'toStartOfMonth'
  }.freeze

  def show
    filters = params[:filter]
    @customer_acc_id = current_customer.allowed_accounts_uuid_ids_hash[filters['account-id-eq']]

    if @customer_acc_id.nil?
      head 500
      return
    end

    @sampling_fn = SAMPLINGS[params[:sampling]]
    if @sampling_fn.nil?
      head 500
      return
    end

    filters = []
    filters.push('time_start>={time_start_gteq: DateTime}')
    filters.push('time_start<{time_start_lt: DateTime}') unless params[:time_start_lt].nil?

    q = "
      SELECT
        toUnixTimestamp(#{@sampling_fn}(time_start)) as t,
        count(*) AS total_calls,
        countIf(duration>0) as successful_calls,
        countIf(duration=0) as failed_calls,
        sum(duration) as total_duration,
        round(avgIf(duration, duration>0),5) AS acd,
        round(countIf(duration>0)/count(*),5) AS asr
      FROM cdrs
      WHERE customer_acc_id = {customer_account_id_eq: UInt32} AND #{filters.join(' AND ')} AND is_last_cdr = true
      GROUP BY t
      ORDER BY t
      FORMAT JSONColumns
    "
    response = ClickHouse.connection.execute(
      q, nil,
      params: {
        param_time_start_gteq: '2023-06-01 00:00:00',
        param_time_start_lt: '2023-06-26 00:00:00',
        param_customer_account_id_eq: @customer_acc_id
      }
    )
    if response.status == 200
      render json: response.body, status: 200
    else
      head 500
    end
  end
end
