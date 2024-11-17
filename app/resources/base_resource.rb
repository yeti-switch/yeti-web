# frozen_string_literal: true

class BaseResource < JSONAPI::Resource
  abstract

  class_attribute :create_form_class_name, instance_writer: false
  class_attribute :update_form_class_name, instance_writer: false

  def self.save_form(class_name)
    create_form(class_name)
    update_form(class_name)
  end

  def self.create_form(class_name)
    if class_name.nil?
      self.create_form_class_name = nil
      define_method(:wrap_create_form) { nil }
      define_method(:unwrap_create_form) { nil }
      return
    end

    self.create_form_class_name = class_name.to_s
    define_method(:wrap_create_form) { @model = create_form_class_name.constantize.new(_model) }
    define_method(:unwrap_create_form) { @model = _model.model }
    before_create(:wrap_create_form)
    after_create(:unwrap_create_form)
  end

  def self.update_form(class_name)
    if class_name.nil?
      self.update_form_class_name = nil
      define_method(:wrap_update_form) { nil }
      define_method(:unwrap_update_form) { nil }
      return
    end

    self.update_form_class_name = class_name.to_s
    define_method(:wrap_update_form) { @model = update_form_class_name.constantize.new(_model) }
    define_method(:unwrap_update_form) { @model = _model.model }
    before_update(:wrap_update_form)
    after_update(:unwrap_update_form)
  end

  def self.type(custom_type)
    self._type = custom_type
  end

  # @param attr [Symbol] filter prefix
  # @param type [Symbol] filter type
  #   @see RansackFilterBuilder::RANSACK_TYPE_SUFIXES_DIC
  # @param column [Symbol]
  # @param verify [Proc, nil] custom validate/change values (receives [Array<String>] values)
  def self.ransack_filter(attr, type:, column: nil, verify: nil, collection: nil, default: nil)
    raise ArgumentError, "type #{type} is not supported" unless RansackFilterBuilder.type_supported?(type)
    raise ArgumentError, ":collection option for type #{type} is not supported" if collection && type != :enum

    suffixes = RansackFilterBuilder.suffixes_for_type(type)
    if default
      wrong_suffixes = default.keys - suffixes.map(&:to_sym)
      raise ArgumentError, "ransack_filter :#{attr} has wrong default suffixes: #{wrong_suffixes.join(', ')}" if wrong_suffixes.any?
    end
    suffixes.each do |suf|
      builder = RansackFilterBuilder.new(attr: attr, operator: suf, column: column, verify: verify, collection: collection)
      filter builder.filter_name,
             verify: ->(values, _ctx) { builder.verify(values) },
             apply: ->(records, values, _opts) { builder.apply(records, values) },
             # see JsonapiRequestParserPatch#set_default_filters
             default: default&.fetch(suf.to_sym, nil)
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

  def self.concat_table_field(table, field, quoted = false)
    if table.blank? || field.to_s.include?('.')
      if quoted
        quote(field)
      else
        field.to_s
      end
    elsif quoted
      # https://github.com/cerebris/jsonapi-resources/issues/1369
      # original: "#{quote(table)}.#{quote(field)}"
      # start patch
      quoted_table = ActiveRecord::Base.connection.quote_table_name(table)
      quoted_field = ActiveRecord::Base.connection.quote_column_name(field)
      "#{quoted_table}.#{quoted_field}"
      # end patch
    else
      "#{table}.#{field}"
    end
  end

  def self.alias_table_field(table, field, quoted = false)
    if table.blank? || field.to_s.include?('.')
      if quoted
        quote(field)
      else
        field.to_s
      end
    elsif quoted
      # https://github.com/cerebris/jsonapi-resources/issues/1369
      # original: quote("#{table}_#{field}")
      # start patch
      quote("#{table.tr('.', '_')}_#{field}")
      # end patch
    else
      # original: "#{table}_#{field}"
      # start patch
      "#{table.tr('.', '_')}_#{field}"
      # end patch
    end
  end

  def self.apply_filter(records, filter, value, options = {})
    strategy = _allowed_filters.fetch(filter.to_sym, {})[:apply]

    if strategy
      records = call_method_or_proc(strategy, records, value, options)
    else
      join_manager = options.dig(:_relation_helper_options, :join_manager)
      field = join_manager ? get_aliased_field(filter, join_manager) : filter
      # https://github.com/cerebris/jsonapi-resources/issues/1369
      # original: records = records.where(Arel.sql(field) => value)
      # start patch
      if field.include?('.')
        parts = field.split('.')
        table = parts[0..-2].join('.')
        field = parts[-1]
        # {"class4.destinations.id" => 123 } -> { "class4_destinations" => { "id" => 123 } }
        # because records.where("class4.destinations.id" => 123) will produce SQL like "WHERE class4.destinations = 123"
        records = records.where(Arel.sql(table) => { Arel.sql(field) => value })
      else
        records = records.where(Arel.sql(field) => value)
      end
      # end patch
    end

    records
  end
end
