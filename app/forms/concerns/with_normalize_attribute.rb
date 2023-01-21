# frozen_string_literal: true

# see https://github.com/rails/rails/commit/d4c31bd8497a4f8c7ed44607076da6d54420f57a
module WithNormalizeAttribute
  extend ActiveSupport::Concern

  class_methods do
    def normalize_attribute(attr_name, with:, apply_to_nil: false)
      attr_name = attr_name.to_sym
      with_proc = with.is_a?(Proc) ? with : proc { |val| val.public_send(with) }
      normalized_attributes << attr_name unless normalized_attributes.include?(attr_name)
      orig_type = attribute_types[attr_name]
      type = NormalizedValueType.new(cast_type: orig_type, normalizer: with_proc, normalize_nil: apply_to_nil)
      default_attr = _default_attributes[attr_name.to_s]
      default = begin
                  default_attr.send(:user_provided_value)
                rescue StandardError
                  nil
                end
      attribute attr_name, type, default: default
    end

    def normalize(name, value)
      type_for_attribute(name).cast(value)
    end

    private

    def inherited(subclass)
      subclass.normalized_attributes = normalized_attributes.dup
      super
    end
  end

  included do
    class_attribute :normalized_attributes, instance_accessor: false, default: []
    before_validation :normalize_changed_in_place_attributes
  end

  # Normalizes a specified attribute using its declared normalizations.
  def normalize_attribute(name)
    # Treat the value as a new, unnormalized value.
    self[name] = self[name]
  end

  def normalize_changed_in_place_attributes
    self.class.normalized_attributes.each do |name|
      normalize_attribute(name) if attribute_changed_in_place?(name)
    end
  end
end
