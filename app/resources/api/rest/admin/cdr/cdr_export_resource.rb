# frozen_string_literal: true

class Api::Rest::Admin::Cdr::CdrExportResource < BaseResource
  model_name 'CdrExport'
  model_hint model: CdrExport::Base, resource: self
  paginator :paged

  attributes :fields,
             :filters,
             :status,
             :created_at,
             :callback_url,
             :export_type

  def filters
    _model.filters.as_json
  end

  def filters=(f)
    if f.key?('src_country_iso_eq')
      src_country = System::Country.find_by(iso2: f['src_country_iso_eq'])
      raise JSONAPI::Exceptions::InvalidFieldValue.new(:src_country_iso_eq, f['src_country_iso_eq']) if src_country.nil?

      f.delete('src_country_iso_eq')
      f[:src_country_id_eq] = src_country.id
    end

    if f.key?('dst_country_iso_eq')
      dst_country = System::Country.find_by(iso2: f['dst_country_iso_eq'])
      raise JSONAPI::Exceptions::InvalidFieldValue.new(:dst_country_iso_eq, f['dst_country_iso_eq']) if dst_country.nil?

      f.delete('dst_country_iso_eq')
      f[:dst_country_id_eq] = dst_country.id
    end

    _model.filters = f
  end

  def self.creatable_fields(_context)
    %i[fields filters callback_url export_type]
  end

  def _remove
    @model.update!(status: CdrExport::STATUS_DELETED)
    :completed
  end
end
