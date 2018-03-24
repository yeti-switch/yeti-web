class Api::Rest::Admin::Cdr::CdrExportResource < ::BaseResource
  model_name 'CdrExport'

  attributes :fields,
    :filters,
    :status,
    :created_at,
    :callback_url,
    :export_type

  def self.creatable_fields(_context)
    [:fields, :filters, :callback_url, :export_type]
  end
end
