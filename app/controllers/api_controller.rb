# frozen_string_literal: true

class ApiController < ActionController::API
  around_action :db_logging

  def db_logging
    if debug_mode
      current_db_connection.execute('set log_duration to on;')
      current_db_connection.execute("set log_statement to 'all';")

    end
    begin
      yield
    ensure
      if debug_mode
        begin
          current_db_connection.execute('set log_duration to off;')
          current_db_connection.execute("set log_statement to 'none';")
        rescue StandardError => e
          Rails.logger.warn e.message
        end
      end
    end
  end

  include WithPayloads
  include CaptureError::ControllerMethods
  include Memoizable

  define_memoizable :debug_mode, apply: -> { System::ApiLogConfig.exists?(controller: self.class.name) }

  rescue_from StandardError, with: :capture_error!

  def meta
    nil
  end

  protected

  def current_db_connection
    ApplicationRecord.connection
  end

  def info_for_paper_trail
    { ip: request.env['HTTP_X_REAL_IP'] || request.remote_ip }
  end

  def user_for_paper_trail
    'API'
  end
end
