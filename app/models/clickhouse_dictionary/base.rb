# frozen_string_literal: true

module ClickhouseDictionary
  class Base
    class_attribute :_model_class, instance_writer: false
    class_attribute :_attributes, instance_writer: false, default: {}

    class << self
      def model_class(klass)
        self._model_class = klass
      end

      def attribute(name, sql: nil)
        self._attributes = _attributes.merge name.to_sym => sql || name
      end

      def attributes(*names)
        options = names.extract_options!
        names.each { |name| attribute(name, **options.dup) }
      end

      def call
        new.call
      end
    end

    def call
      fields = attribute_names
      rows = scoped_collection.pluck(Arel.sql(pluck_fields.join(', '))).map { |values| fields.zip(values).to_h }
      rows.map(&:to_json).join("\n")
    end

    private

    def scoped_collection
      _model_class.all
    end

    def pluck_fields
      _attributes.values
    end

    def attribute_names
      _attributes.keys
    end
  end
end
