# frozen_string_literal: true

class Api::Rest::Customer::V1::CdrExportsController < Api::Rest::Customer::V1::BaseController
  before_action :find_cdr_export, only: :download
  include ActionController::Live

  def download
    if @cdr_export.completed?
      Cdr::DownloadCdrExport.call(cdr_export: @cdr_export, response_object: response, public: true)
    else
      head 404
    end
  rescue Cdr::DownloadCdrExport::NotFoundError
    head 404
  rescue StandardError => e
    handle_exceptions(e)
  ensure
    response.stream.close
  end

  private

  def find_cdr_export
    resource_klass = Api::Rest::Customer::V1::CdrExportResource
    key = resource_klass.verify_key(params[:id], context)
    @cdr_export = resource_klass.find_by_key(key, context: context)._model
  rescue StandardError => e
    handle_exceptions(e)
  end
end
