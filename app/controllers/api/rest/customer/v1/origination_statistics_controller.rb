# frozen_string_literal: true

class Api::Rest::Customer::V1::OriginationStatisticsController < Api::RestController
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
    @customer_acc_id = current_customer.allowed_accounts_uuid_ids_hash[params['account-id']]
    if @customer_acc_id.nil?
      head 500
      return
    end

    @sampling_fn = SAMPLINGS[params[:sampling]]
    if @sampling_fn.nil?
      head 500
      return
    end

    if params['from-time'].nil?
      head 500
      return
    end

    filters = []
    query_params = {}

    filters.push('customer_acc_id = {account_id: UInt32}')
    query_params['param_account_id'] = @customer_acc_id

    filters.push('time_start>={from_time: DateTime}')
    query_params['param_from_time'] = params['from-time']

    unless params['to-time'].nil?
      filters.push('time_start<{to_time: DateTime}')
      query_params['param_to_time'] = params['to-time']
    end

    q = "
      SELECT
        toUnixTimestamp(#{@sampling_fn}(time_start)) as t,
        count(*) AS total_calls,
        countIf(duration>0) as successful_calls,
        countIf(duration=0) as failed_calls,
        sum(duration) as total_duration,
        round(avgIf(duration, duration>0),5) AS acd,
        round(countIf(duration>0)/count(*),5) AS asr,
        sum(customer_price) as total_price
      FROM cdrs
      WHERE #{filters.join(' AND ')} AND is_last_cdr = true
      GROUP BY t
      ORDER BY t
      FORMAT JSONColumns
    "

    response = ClickHouse.connection.execute(
      q, nil,
      params: query_params
    )
    if response.status == 200
      render json: response.body, status: 200
    else
      head 500
      nil
    end
  end
end
