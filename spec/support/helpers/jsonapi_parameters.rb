# frozen_string_literal: true

module Helpers
  module JsonapiParameters
    # Defines filters for resource.
    # @see JSONAPI::Resource._allowed_filters.
    # @param filters [Hash<Symbol,String>,Hash]
    # @param descriptions [Hash<Symbol,String>,Hash] override description for filter
    def jsonapi_filters(filters, descriptions = {})
      filters.each do |attr, opts|
        description = opts[:desc] || descriptions[attr]
        jsonapi_filter(attr, description)
      end
    end

    # Define filter for endpoint
    # @param attr [Symbol,String] filter name
    # @param description [String,nil] optional description
    def jsonapi_filter(attr, description = nil)
      description ||= "#{attr.to_s.tr('_', ' ')} filter"

      define_parameter attr, desc: description, scope: :filter
    end

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

    private

    def define_parameter(sym, options = {})
      param_name = sym.to_s.dasherize
      description = options.delete(:desc) || param_name.capitalize.tr('-', ' ')
      parameter param_name, description, **options
    end

    def jsonapi_extract_fields_data(resource_class, format: :dasherize, context: {})
      format_proc = proc { |attr| attr.to_s.public_send(format).to_sym }
      options = { context: context }
      relationships = resource_class._relationships.keys.map(&format_proc)
      creatable_fields = resource_class.creatable_fields(options).map(&format_proc)
      updatable_fields = resource_class.updatable_fields(options).map(&format_proc)
      resource = resource_class.new(resource_class._model_class.new, context)
      fetchable_fields = resource.fetchable_fields.map(&format_proc)
      creatable_attributes = creatable_fields - relationships
      updatable_attributes = updatable_fields - relationships
      fetchable_attributes = fetchable_fields - relationships
      creatable_relationships = relationships - creatable_attributes
      updatable_relationships = relationships - updatable_attributes
      fetchable_relationships = relationships - fetchable_attributes

      {
        creatable_attributes: creatable_attributes,
        updatable_attributes: updatable_attributes,
        fetchable_attributes: fetchable_attributes,
        creatable_relationships: creatable_relationships,
        updatable_relationships: updatable_relationships,
        fetchable_relationships: fetchable_relationships
      }
    end
  end
end

RSpec.configure do |config|
  config.extend Helpers::JsonapiParameters
end
