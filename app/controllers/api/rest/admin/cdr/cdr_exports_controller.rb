# frozen_string_literal: true

class Api::Rest::Admin::Cdr::CdrExportsController < Api::Rest::Admin::BaseController
  before_action :find_cdr_export, only: :download

  def download
    if @cdr_export.completed?
      response.headers['X-Accel-Redirect'] = "/x-redirect/cdr_export/#{@cdr_export.id}.csv.gz"
      response.headers['Content-Type'] = 'text/csv; charset=utf-8'
      response.headers['Content-Disposition'] = "attachment; filename=\"#{@cdr_export.id}.csv.gz\""
      render body: nil
    else
      head 404
    end
  rescue StandardError => e
    handle_exceptions(e)
  end

  private

  def find_cdr_export
    resource_klass = Api::Rest::Admin::Cdr::CdrExportResource
    key = resource_klass.verify_key(params[:id], context)
    @cdr_export = resource_klass.find_by_key(key, context: context)._model
  rescue StandardError => e
    handle_exceptions(e)
  end
end
