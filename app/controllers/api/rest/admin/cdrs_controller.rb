# frozen_string_literal: true

class Api::Rest::Admin::CdrsController < Api::Rest::Admin::BaseController
  include TryCdrReplica

  # rubocop:disable Rails/LexicallyScopedActionFilter
  around_action :try_cdr_replica, only: %i[index show recording]
  # rubocop:enable Rails/LexicallyScopedActionFilter
  before_action :find_cdr, only: :recording

  def recording
    if @cdr.has_recording?
      response.headers['X-Accel-Redirect'] = @cdr.call_record_filename
      response.headers['Content-Type'] = @cdr.call_record_ct
      render body: nil
    else
      head 404
    end
  rescue StandardError => e
    handle_exceptions(e)
  end

  private

  def find_cdr
    resource_klass = Api::Rest::Admin::CdrResource
    key = resource_klass.verify_key(params[:id], context)
    @cdr = resource_klass.find_by_key(key, context: context)._model
  rescue StandardError => e
    handle_exceptions(e)
  end
end
