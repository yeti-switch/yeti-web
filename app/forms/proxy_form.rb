# frozen_string_literal: true

class ProxyForm < ApplicationForm
  abstract
  with_transaction

  class_attribute :_model_class_name, instance_writer: false
  delegate :_model_class, to: :class
  delegate :id, to: :model

  class << self
    def model_class(class_name)
      self._model_class_name = class_name.to_s
    end

    def _model_class
      _model_class_name.constantize
    end

    def model_attribute(name)
      delegate name, "#{name}=", "#{name}_changed?", to: :model
    end

    def model_attributes(*names)
      names.each { |name| model_attribute(name) }
    end
  end

  attr_reader :model
  validate :validate_model

  def initialize(model = nil, attributes = nil)
    if attributes.nil? && (model.is_a?(Hash) || model.is_a?(ActionController::Parameters))
      attributes = model
      model = nil
    end

    @model = model || _model_class.new
    super(attributes || {})
  end

  def to_param
    id
  end

  def persisted?
    id.present?
  end

  private

  def _save
    # Model errors can be added in before_save/after_save callbacks
    # so we need to propagate them too.
    unless model.save(validate: false)
      propagate_errors(model)
      throw(:error)
    end
  end

  def validate_model
    unless model.valid?
      propagate_errors(model)
    end
  end

  def propagate_errors(record)
    record.errors.each do |error|
      attribute, message = transform_model_error(error.attribute, error.message)
      errors.add(attribute, message)
    end
  end

  def transform_model_error(attribute, message)
    [attribute, message]
  end

  def transaction_class
    _model_class
  end
end
