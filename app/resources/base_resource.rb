# frozen_string_literal: true

class BaseResource < JSONAPI::Resource
  abstract

  def self.type(custom_type)
    self._type = custom_type
  end

  # @param attr [Symbol] filter prefix
  # @param type [Symbol] filter type
  #   @see RansackFilterBuilder::RANSACK_TYPE_SUFIXES_DIC
  # @param column [Symbol]
  # @param verify [Proc, nil] custom validate/change values (receives [Array<String>] values)
  def self.ransack_filter(attr, type:, column: nil, verify: nil)
    raise ArgumentError, "type #{type} is not supported" unless RansackFilterBuilder.type_supported?(type)

    RansackFilterBuilder.suffixes_for_type(type).each do |suf|
      builder = RansackFilterBuilder.new(attr: attr, operator: suf, column: column, verify: verify)
      filter builder.filter_name,
             verify: ->(values, _ctx) { builder.verify(values) },
             apply: ->(records, values, _opts) { builder.apply(records, values) }
    end
  end

  def self.relationship_filter(name, options = {})
    foreign_key = options.fetch(:foreign_key, :"#{name}_id")

    filter :"#{name}.id", apply: lambda { |records, values, _options|
      records.where(foreign_key => values)
    }
  end

  def self.has_one(name, options = {})
    super name, options.except(:force_routed)
    _relationships[name.to_sym]._routed = true if options.fetch(:force_routed, false)
  end

  # Was rewritten from version 0.9.12
  def self.resolve_relationship_names_to_relations(resource_klass, model_includes, options = {})
    case model_includes
    when Array
      model_includes.map do |value|
        resolve_relationship_names_to_relations(resource_klass, value, options)
      end
    when Hash
      model_includes.keys.each do |key| # rubocop:disable Style/HashEachMethods
        relationship = resource_klass._relationships[key]
        value = model_includes[key]
        model_includes.delete(key)
        # Below 1 line was removed
        # model_includes[relationship.relation_name(options)] = resolve_relationship_names_to_relations(relationship.resource_klass, value, options)
        # Below 4 lines was added
        required_includes = relationship.relation_includes(options)
        nested_includes = resolve_relationship_names_to_relations(relationship.resource_klass, value, options)
        nested_includes = combine_model_includes(nested_includes, required_includes) unless required_includes.empty?
        model_includes[relationship.relation_name(options)] = nested_includes
      end
      model_includes
    when Symbol
      relationship = resource_klass._relationships[model_includes]
      # Below 1 line was removed
      # return relationship.relation_name(options)
      # Below 3 line was added
      relation_name = relationship.relation_name(options)
      required_includes = relationship.relation_includes(options)
      required_includes.empty? ? relation_name : { relation_name => required_includes }
    end
  end

  def self.records(context)
    scope = super
    apply_required_model_includes(scope, context)
  end

  def self.apply_required_model_includes(records, context)
    model_includes = required_model_includes(context)
    records = records.includes(*model_includes) unless model_includes.empty?
    records
  end

  def self.required_model_includes(_context)
    []
  end

  def self.combine_model_includes(model_includes, extra_includes)
    model_includes = Array.wrap(model_includes)
    extra_includes = Array.wrap(extra_includes)
    model_includes_opts = model_includes.extract_options!
    extra_includes_opts = extra_includes.extract_options!

    includes_opts = model_includes_opts.deep_merge(extra_includes_opts)
    includes = model_includes + extra_includes + [includes_opts]
    includes = includes.first if includes.size == 1
    includes
  end
end
