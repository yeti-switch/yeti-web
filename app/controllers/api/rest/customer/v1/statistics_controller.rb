class Api::Rest::Customer::V1::StatisticsController < Api::RestController
  include CustomerV1Authorizable
  include ActionController::Cookies

  before_action :authorize!
  after_action :setup_authorization_cookie

  SAMPLINGS = {
    'minute' => 'toStartOfMinute',
    '5minutes' => 'toStartOfMinute5minutes',
    'hour' => 'toStartOfHour',
    'day' => 'toStartOfDay'
  }.freeze

  def show
    @sampling_fn = SAMPLINGS[params[:sampling]]
    if @sampling_fn.nil?
      head 500
    end

    filters = []
    filters.push('time_start>={time_start_gteq: DateTime}')
    filters.push('time_start<{time_start_lt: DateTime}') unless params[:time_start_lt].nil?
    filters.push('customer_acc_id = {customer_account_id_eq: UInt32}')
    filters.push('is_last_cdr = true')

    q = "
      SELECT
        toUnixTimestamp(#{@sampling_fn}(time_start)) as t,
        count(*) AS counter
      FROM cdrs
      WHERE #{filters.join(' AND ')}
      GROUP BY t
      ORDER BY t
      FORMAT JSON
    "
    response = ClickHouse.connection.execute(
      q, nil,
      params: {
        param_time_start_gteq: '2023-02-01 00:00:00',
        param_time_start_lt: '2023-02-01 00:00:00',
        param_customer_account_id_eq: 22
      }
    )

    # head 200
    render json: { data: response.body['data'] }, status: 200
  end
end
