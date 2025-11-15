# frozen_string_literal: true

class Api::Rest::Customer::V1::TerminationActiveCallsController < Api::RestController
  include CustomerV1Authorizable
  include ActionController::Cookies

  before_action :authorize!
  after_action :setup_authorization_cookie

  def show
    statistic = ClickhouseReport::TerminationActiveCalls.new(params.to_unsafe_h, auth_context:)

    begin
      rows = statistic.collection
      render json: rows, status: 200
    rescue ClickhouseReport::Base::FromDateTimeInFutureError => e
      Rails.logger.error { "<#{e.class}>: #{e.message}" }
      render json: [], status: 200
    rescue ClickhouseReport::Base::ParamError => e
      Rails.logger.error { "Bad Request <#{e.class}>: #{e.message}" }
      render json: { error: e.message }, status: 400
    rescue ClickhouseReport::Base::Error, StandardError => e
      Rails.logger.error { "Server Error <#{e.class}>: #{e.message}" }
      CaptureError.capture(e, extra: { params: params.to_unsafe_h })
      head 500
    end
  end
end
