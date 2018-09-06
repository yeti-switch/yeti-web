class Api::Rest::Admin::Cdr::CdrExportResource < ::BaseResource
  model_name 'CdrExport'
  model_hint model: CdrExport::Base, resource: self

  attributes :fields,
    :filters,
    :status,
    :created_at,
    :callback_url,
    :export_type

  def self.creatable_fields(_context)
    [:fields, :filters, :callback_url, :export_type]
  end

  def _remove
    @model.update!(status: CdrExport::STATUS_DELETED)
    :completed
  end
end
