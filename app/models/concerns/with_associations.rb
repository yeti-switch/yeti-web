# frozen_string_literal: true

module WithAssociations
  extend ActiveSupport::Concern

  included do
    class_attribute :association_types, instance_accessor: false, default: {}

    def initialize(*)
      @associations = {}
      super
    end

    def associations
      @associations
    end

    private

    def retrieve_association(name)
      return associations[name] if associations.key?(name)

      opts = self.class.association_types[name.to_s]
      foreign_key_value = public_send(opts[:foreign_key])
      return if foreign_key_value.nil?

      records = self.class.fetch_associations(name, [foreign_key_value])
      associations[name] = opts[:type] == :has_many ? records : records.first
    end
  end

  class_methods do
    def has_one(name, options = {})
      register_association(name, :has_one, **options)
    end

    def register_association(name, type, class_name:, foreign_key: nil, primary_key: 'id', **options)
      foreign_key ||= "#{name}_id"
      assoc_opts = {
        class_name: class_name,
        foreign_key: foreign_key.to_s,
        primary_key: primary_key.to_s,
        type: type,
        **options
      }
      self.association_types = association_types.merge(name.to_s => assoc_opts)
      define_method(name) { retrieve_association(name.to_sym) }
      define_method("#{name}=") { |value| associations[name.to_sym] = value }
    end

    def fetch_associations(name, foreign_key_values, includes = [])
      opts = association_types[name.to_s]
      klass = opts[:class_name].constantize
      primary_key = opts[:primary_key].to_sym

      scope = klass.where(primary_key => foreign_key_values)
      scope = scope.preload(*includes) if includes.present?
      scope.to_a
    end

    def load_association(records, assoc_name, includes = [])
      assoc_opts = association_types[assoc_name.to_s]
      klass = assoc_opts[:class_name].constantize
      primary_key = (assoc_opts[:primary_key] || :id).to_sym
      foreign_key = assoc_opts[:foreign_key]
      foreign_key_values = records.collect { |record| record.public_send(foreign_key) }.uniq

      assoc_scope = klass.where(primary_key => foreign_key_values)
      assoc_scope = assoc_scope.preload(*includes) if includes.present?
      assoc_collection = assoc_scope.index_by(&primary_key)
      if assoc_collection.any?
        records.each do |record|
          record.public_send "#{assoc_name}=", assoc_collection[record.public_send(foreign_key)]
        end
      end
    end

    def load_associations(records, *includes)
      includes_nested = includes.extract_options!
      includes.each { |name| load_association(records, name) }
      includes_nested.each { |name, nested| load_association(records, name, nested) }
    end
  end
end
