# frozen_string_literal: true

module JsonapiRelationshipPatch
  def initialize(name, options = {})
    super
    @required_includes = options[:required_includes]
  end

  def relation_includes(options)
    case @required_includes
    when NilClass
      resource_klass.required_model_includes(options[:context])
    when Proc
      @required_includes.call(options[:context])
    else
      @required_includes
    end
  end
end

JSONAPI::Relationship.prepend JsonapiRelationshipPatch
