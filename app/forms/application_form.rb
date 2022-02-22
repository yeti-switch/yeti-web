# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Attributes
  include ActiveModel::Dirty
  extend ActiveModel::Callbacks
  include WithActiveModelArrayAttribute
  include Memoizable
  include CaptureError::BaseMethods

  class Error < StandardError
  end

  class RecordInvalid < Error
    def initialize(obj)
      if obj.errors.any?
        message = "Validation failed: #{obj.errors.full_messages.join(', ')}"
      else
        message = 'Save failed'
      end
      super(message)
    end
  end

  Reflection = Struct.new(:name, :type, :class_name, :options) do
    def klass
      class_name.constantize
    end

    def many?
      type == :collection
    end

    def default_value(record)
      if !option.key?(:default)
        many? ? [] : nil
      elsif option[:default].is_a?(Proc)
        record.instance_exec &option[:default]
      else
        option[:default]
      end
    end

    def build(attributes)
      if many?
        attributes = attributes.values unless attributes.is_a?(Array)
        attributes.map { |attrs| klass.new(attrs) }
      else
        klass.new(attributes)
      end
    end
  end

  class_attribute :_abstract, instance_writer: false, default: true
  class_attribute :_reflections, instance_writer: false, default: {}

  # Required by activeadmin https://github.com/activeadmin/activeadmin/pull/5253#discussion_r155525109
  class_attribute :inheritance_column, instance_accessor: false, default: nil

  class << self
    def inherited(subclass)
      subclass.with_transaction(true) if with_transaction?
      subclass._reflections = _reflections.dup
      subclass._abstract = false
      super
    end

    def association(name, type, class_name, options = {})
      name = name.to_sym
      _reflections[name] = Reflection.new(name, type.to_sym, class_name.to_s, options)

      define_method(name) { read_association(name) }
      define_method("#{name}=") { |value| write_association(name, value) }
      define_method("#{name}_changed?") { association_changed?(name) }
      define_method("#{name}_attributes=") do |attributes|
        value = _reflections[name].build(attributes)
        write_association(name, value)
      end
    end

    def has_one(name, class_name:, **options)
      association(name, :single, class_name, options)
    end

    def has_many(name, class_name:, **options)
      association(name, :collection, class_name, options)
    end

    def reflect_on_association(assoc_name)
      _reflections[assoc_name.to_sym]
    end

    def with_transaction(flag = true)
      @with_transaction = flag
    end

    def with_transaction?
      defined?(@with_transaction) && @with_transaction
    end

    def column_for_attribute(name) # for formtastic
      attribute_types.fetch(name.to_s) do
        ActiveModel::Type::Value.new
      end
    end

    def with_model_name(name, namespace: nil)
      define_singleton_method(:model_name) do
        @_model_name ||= ActiveModel::Name.new(self, namespace, name)
      end
    end

    def with_policy_class(class_name)
      define_singleton_method(:policy_class) do
        class_name.constantize
      end
    end

    def abstract(flag = true)
      self._abstract = flag
    end
  end

  class_attribute :logger, instance_writer: false, default: Rails.logger
  delegate :with_transaction?, :column_for_attribute, to: :class
  define_model_callbacks :save
  define_model_callbacks :create
  define_model_callbacks :update
  define_model_callbacks :initialize, only: :after

  # @param attributes [Hash,ActionController::Parameters,nil]
  def initialize(attributes = {})
    raise ArgumentError, "can't initialize abstract form #{self.class}" if _abstract

    # after_initialize callback will be called before provided attributes assigned.
    run_callbacks(:initialize) do
      super({})
      @associations = default_associations
      @association_changes = []
    end
    assign_attributes(attributes) if attributes
  end

  # override #persisted? method if needed.
  def new_record?
    !persisted?
  end

  # @return [Boolean]
  def persisted?
    false
  end

  def save(opts = {})
    operation = new_record? ? :create : :update
    validate = opts.fetch(:validate, true)
    validation_context = opts.fetch(:validation_context, operation)

    if !validate || valid?(validation_context)
      begin
        within_transaction do
          saved = catch(:error) do
            run_callbacks(operation) do
              run_callbacks(:save) { _save }
            end
            true
          end
          # Needed for proper transaction rollback.
          raise ActiveRecord::Rollback unless saved
        end
      rescue ActiveRecord::Rollback => _
        # We need to catch this error for cases when
        # form save ont within transaction.
        false
      rescue ActiveRecord::RecordInvalid => e
        log_error(e)
        capture_error(e)
        message = e.record ? e.record.errors.full_messages.join(', ') : e.message
        errors.add(:base, message)
      rescue StandardError => e
        log_error(e)
        capture_error(e)
        errors.add(:base, e.message)
      end
      errors.empty?
    else
      false
    end
  end

  def save!
    save || (raise RecordInvalid, self)
  end

  def capture_tags
    { component: 'FormObject', form_object_name: self.class.name }
  end

  def association_changed?(name)
    @association_changes.include?(name.to_sym)
  end

  private

  def default_associations
    result = {}
    reflections_with_default = _reflections.select { |_, ref| ref.options.key?(:default) }
    reflections_with_default.each do |name, reflection|
      result[name] = reflection.default_value(self)
    end
    result
  end

  def read_association(name)
    @associations[name]
  end

  def write_association(name, value)
    association_will_change!(name)
    @associations[name] = value
  end

  def association_will_change!(name)
    @association_changes.push(name) unless association_changed?(name)
  end

  # override this method in a subclass
  def _save
    raise NotImplementedError
  end

  def within_transaction
    return yield unless with_transaction?

    transaction_class.transaction { yield }
  end

  def transaction_class
    ApplicationRecord
  end
end
