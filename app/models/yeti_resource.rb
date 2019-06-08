# frozen_string_literal: true

class YetiResource
  FakeColumn = Struct.new(:name)

  include ActiveModel::Model
  include ActiveModel::Serializers::Xml
  include ActiveModel::Attributes
  include WithAssociations

  class_attribute :logger, instance_writer: false, default: Rails.logger

  class << self
    # for csv export
    def content_columns
      return @content_columns if defined?(@content_columns)

      @content_columns = attribute_types.keys.map do |name|
        FakeColumn.new(name: name.to_sym)
      end
    end

    def column_names
      content_columns
    end

    def human_attribute_name(attribute_key_name, _options = {})
      attribute_key_name
    end
  end

  def to_param
    id
  end

  attr_accessor :_rest_attributes

  private

  def _assign_attribute(k, v)
    super
  rescue ActiveModel::UnknownAttributeError
    self._rest_attributes ||= {}
    _rest_attributes.merge!(k => v)
  end
end
