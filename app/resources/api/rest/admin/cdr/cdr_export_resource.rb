# frozen_string_literal: true

class Api::Rest::Admin::Cdr::CdrExportResource < BaseResource
  model_name 'CdrExport'
  model_hint model: CdrExport::Base, resource: self

  attributes :fields,
             :filters,
             :status,
             :created_at,
             :callback_url,
             :export_type

  #ransack_filter :fields, type: :string   ARRAY
  #ransack_filter :filters,  type: :json
  ransack_filter :status, type: :string
  #ransack_filter :created_at, type: datetime
  ransack_filter :callback_url, type: :string

  def self.creatable_fields(_context)
    %i[fields filters callback_url export_type]
  end

  def _remove
    @model.update!(status: CdrExport::STATUS_DELETED)
    :completed
  end
end
