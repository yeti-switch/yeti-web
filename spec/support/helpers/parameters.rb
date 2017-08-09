module Helpers
  module Parameters
    def define_parameters(required, optional)
      required.each { |e| define_parameter(e, required: true) }
      optional.each { |e| define_parameter(e) }
    end

    def define_parameter(sym, options = {})
      param_name = sym.to_s.dasherize
      parameter param_name, param_name.capitalize.gsub('-', ' '), scope: [:data, :attributes], **options
    end
  end
end

RSpec.configure do |config|
  config.extend Helpers::Parameters
end
