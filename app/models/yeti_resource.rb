# frozen_string_literal: true

class YetiResource
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Serializers::Xml

  class FakeColumn
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  def self.human_attributes(only = nil)
    # attrs = self::DYNAMIC_ATTRIBUTES -
    #     self::FOREIGN_KEYS_ATTRIBUTES.keys +
    #     self::FOREIGN_KEYS_ATTRIBUTES.keys.collect { |k| k.to_s[0..-4].to_sym }

    attrs = only || self::DYNAMIC_ATTRIBUTES
    # attrs =  attrs & Array.wrap(only) if only
    attrs.map { |e| self::FOREIGN_KEYS_ATTRIBUTES.key?(e) ? e.to_s[0..-4].to_sym : e }
  end

  # for xml export
  def attributes
    data = {}
    self::DYNAMIC_ATTRIBUTES.each do |attr|
      data[attr] = send(attr)
    end
    data
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to?("#{name}=")
    end
  end

  # for csv export
  def self.content_columns
    if @content_columns.nil?
      @content_columns = []
      self::DYNAMIC_ATTRIBUTES.each do |name|
        @content_columns << FakeColumn.new(name)
      end
    end
    @content_columns
  end

  def self.column_names
    content_columns
  end

  def num_pages
    1
  end

  def persisted?
    false
  end

  def sort_order
    self
  end

  def self.collection(array)
    array.map { |el| new(el) }
  end

  def self.assign_foreign_resources(result)
    self::FOREIGN_KEYS_ATTRIBUTES.each do |foreign_key, klass|
      result = assign_resources(result, klass, foreign_key, foreign_key.to_s[0..-4].to_sym)
    end
    result
  end

  def self.assign_resources(result, klass, foreign_key, attribute_name, primary_key = :id)
    collection = klass.where(primary_key => result.collect { |call| call.send(foreign_key) }.uniq).index_by(&primary_key.to_s.to_sym)
    if collection.any?
      result.each do |item|
        item.send("#{attribute_name}=", collection[item.send(foreign_key).to_i])
      end
    end
    result
  end
end
