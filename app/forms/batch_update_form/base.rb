# frozen_string_literal: true

class BatchUpdateForm::Base
  # Base class for batch update form.
  # Usage:
  #
  #   # app/models/batch_update_form/contact.rb
  #   module BatchUpdateForm
  #     class Some < Base
  #       model_class 'SomeModel'
  #       attribute :admin_user_id, type: :foreign_key, class_name: 'AdminUser', display_name: :username
  #       attribute :capacity
  #       attribute :expires_in, type: :date
  #
  #       validate if: :capacity_changed? do
  #         value = Integer(capacity) rescue nil
  #         errors.add(:capacity, :invalid) if value.nil?
  #         errors.add(:capacity, 'must be greater than 0') if value <= 0
  #       end
  #
  #       validate if: :expires_in_changed? do
  #         value = Date.parse(expires_in) rescue nil
  #         errors.add(:expires_in, :invalid) if value.nil?
  #         error.add(:expires_in, "can't be in past") if value < Date.today
  #       end
  #     end
  #   end
  #
  #   # app/admin/billing/contacts.rb
  #   ActiveAdmin.register Billing::Contact do
  #     acts_as_async_update BatchUpdateForm::Contact
  #     # ...
  #   end

  include ActiveModel::Validations

  class_attribute :_attributes, instance_writer: false, default: {}
  class_attribute :_model_class_name, instance_writer: false
  attr_accessor :selected_record

  def initialize(attrs = {})
    attrs.each do |key, value|
      type = self.class._attributes[key.to_sym][:type]
      if value.present? || value.is_a?(String)
        public_send("#{key}=", public_send("type_cast_#{type}", value))
      else
        public_send("#{key}=", value)
      end
    end
  end

  # methods for type casting
  def type_cast_boolean(raw_value)
    ActiveModel::Type::Boolean.new.cast(raw_value)
  end

  def method_missing(method, *args)
    if method.to_s.start_with?('type_cast_')
      args[0]
    else
      super
    end
  end

  class << self
    private def inherited(subclass)
      subclass._attributes = _attributes.dup
      super
    end

    # Set model class.
    # @param [String,Class<ApplicationRecord>]
    def model_class(class_name)
      self._model_class_name = class_name.to_s
    end

    def _model_class
      @_model_class ||= _model_class_name.constantize
    end

    # Define form attribute.
    # Defines method "#{name}_changed?" to check whether attribute passed or not
    # @param name [Symbol]
    # @param options [Hash]
    #  :type [Symbol] default :text.
    #  other options depends on type (@see form_data_#{type} method).
    def attribute(name, options = {})
      _attributes[name] = options
      attr_accessor(name)
      define_method("#{name}_changed?") { attribute_changed?(name) }
    end

    # Needed for active admin scoped collection action to build form.
    # To add new type
    def form_data
      data = {}

      _attributes.each do |name, options|
        type = options.fetch(:type, 'string')
        data[name] = public_send("form_data_#{type}", options)
      end

      data
    end

    def form_data_string(_options)
      'text'
    end

    def form_data_date(_options)
      'datepicker'
    end

    def form_data_boolean(_options)
      [%w[Yes true], %w[No false]]
    end

    # @param options [Hash]
    #   :class_name [String] required.
    #   :display_name [Symbol] default :name.
    #   :primary_key [Symbol] default :id.
    #   :scope [Proc,Symbol,nil] optional.
    # @return [Array<Array(2)>]
    def form_data_foreign_key(options)
      klass = options.fetch(:class_name).constantize
      display_name = options.fetch(:display_name, :name)
      primary_key = options.fetch(:primary_key, :id)
      custom_scope = options[:scope]

      scope = klass.all
      scope = scope.public_send(custom_scope) if custom_scope.is_a?(Symbol)
      scope = custom_scope.call(scope) if custom_scope.is_a?(Proc)
      scope.pluck(display_name, primary_key)
    end
  end

  # @param collection_sql [String]
  # @param paper_trail_info [Hash]
  def perform(collection_sql, paper_trail_info)
    AsyncBatchUpdateJob.perform_later(
      self.class._model_class_name,
      collection_sql,
      attributes,
      paper_trail_info
    )
  end

  # @param name [Symbol]
  # @return [Boolean]
  def attribute_changed?(name)
    !public_send(name).nil?
  end

  # @return [Hash]
  def attributes
    data = {}

    _attributes.each do |name, _|
      data[name] = public_send(name) if attribute_changed?(name)
    end

    data
  end
end
