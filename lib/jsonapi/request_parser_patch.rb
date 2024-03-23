# frozen_string_literal: true

module JsonapiRequestParserPatch
  def set_default_filters
    @resource_klass._allowed_filters.each do |filter, opts|
      next if opts[:default].nil? || !@filters[filter].nil?

      if opts[:default].is_a?(Proc)
        value = opts[:default].call({ params:, context: })
      elsif opts[:default].is_a?(Symbol)
        value = @resource_klass.public_send(opts[:default], { params:, context: })
      else
        value = opts[:default]
      end

      @filters[filter] = value unless value.nil?
    end
  end
end

JSONAPI::RequestParser.prepend(JsonapiRequestParserPatch)
