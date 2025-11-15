# frozen_string_literal: true

class Api::Rest::Customer::V1::CdrsController < Api::Rest::Customer::V1::BaseController
  include TryCdrReplica
  include ActionController::Live

  around_action :try_cdr_replica
  before_action :find_cdr, only: :rec

  def rec
    unless auth_context.allow_listen_recording
      head 404 and return
    end

    Cdr::DownloadCallRecord.call(cdr: @cdr, response_object: response)
  rescue Cdr::DownloadCallRecord::NotFoundError
    head 404
  rescue StandardError => e
    handle_exceptions(e)
  ensure
    response.stream.close
  end

  private

  # possible security issue
  def find_cdr
    resource_klass = Api::Rest::Customer::V1::CdrResource
    key = resource_klass.verify_key(params[:id], context)
    @cdr = resource_klass.find_by_key(key, context: context)._model
  rescue StandardError => e
    handle_exceptions(e)
  end
end
