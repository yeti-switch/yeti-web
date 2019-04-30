# frozen_string_literal: true

module Helpers
  module JsonapiParameters
    HUMANIZE_FILTER_OPERATOR = {
      'eq' => 'equal',
      'not_eq' => 'not equal',
      'gt' => 'greater than',
      'gteq' => 'greater than or equal to',
      'lt' => 'less than',
      'lteq' => 'less than or equal to',
      'in' => 'in',
      'not_in' => 'not in',
      'cont' => 'contain',
      'start' => 'start',
      'end' => 'end',
      'cont any' => 'contain any'
    }
    def jsonapi_attributes(required, optional)
      required.each { |e| jsonapi_attribute(e, required: true) }
      optional.each { |e| jsonapi_attribute(e) }
    end

    def jsonapi_relationships(required, optional)
      required.each { |e| jsonapi_relationship(e, required: true) }
      optional.each { |e| jsonapi_relationship(e) }
    end

    def jsonapi_attribute(name, options = {})
      define_parameter(name, options.merge(scope: %i[data attributes]))
    end

    def jsonapi_relationship(name, options = {})
      define_parameter(name, options.merge(scope: %i[data relationships]))
    end

    def jsonapi_filters(resource)
      resource.filters.keys.each { |f| jsonapi_filter(f) }
    end

    def jsonapi_filter(filter)
      field = filter.to_s.gsub(/_(#{filter_suffixes.join('|')})$/, '')
      operator = filter.to_s.gsub("#{field}_", '')
      desc = if operator.blank?
               'DEPRECATED'
             else
               "Filter by #{field} field with '#{HUMANIZE_FILTER_OPERATOR[operator]}' operator"
             end
      parameter filter, desc, scope: :filter
    end

    private

    def filter_suffixes
      RansackFilterBuilder::RANSACK_TYPE_SUFIXES_DIC.values.sum
    end

    def define_parameter(sym, options = {})
      param_name = sym.to_s.dasherize
      parameter param_name, param_name.capitalize.tr('-', ' '), **options
    end
  end
end

RSpec.configure do |config|
  config.extend Helpers::JsonapiParameters
end
