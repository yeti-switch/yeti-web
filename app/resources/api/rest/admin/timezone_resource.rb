# frozen_string_literal: true

class Api::Rest::Admin::TimezoneResource < ::BaseResource
  model_name 'Yeti::TimeZone'
  immutable
  key_type :string
  attributes :name
  paginator :none
  filter :name
  exclude_links [:self]

  def self.records(_options = {})
    Yeti::TimeZone.all
  end

  def self.apply_sort(records, _order_options, _context = {})
    records
  end

  def self.apply_pagination(records, _paginator, _order_options)
    records
  end

  def self.find_by_key(key, options = {})
    context = options[:context]
    model = records(options).find(key)
    raise JSONAPI::Exceptions::RecordNotFound, key if model.nil?

    new(model, context)
  end

  def self.find_count(_filters, options = {})
    records(options).size
  end
end
