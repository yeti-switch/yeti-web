module Helpers
  module JsonapiParameters
    def jsonapi_attributes(required, optional)
      required.each { |e| jsonapi_attribute(e, required: true) }
      optional.each { |e| jsonapi_attribute(e) }
    end

    def jsonapi_relationships(required, optional)
      required.each { |e| jsonapi_relationship(e, required: true) }
      optional.each { |e| jsonapi_relationship(e) }
    end

    def jsonapi_attribute(name, options = {})
      define_parameter(name, options.merge(scope: [:data, :attributes]))
    end

    def jsonapi_relationship(name, options = {})
      define_parameter(name, options.merge(scope: [:data, :relationships]))
    end

    private

    def define_parameter(sym, options = {})
      param_name = sym.to_s.dasherize
      parameter param_name, param_name.capitalize.gsub('-', ' '), **options
    end
  end
end

RSpec.configure do |config|
  config.extend Helpers::JsonapiParameters
end
