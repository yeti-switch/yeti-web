# frozen_string_literal: true

class ApplicationService
  include Memoizable
  include CaptureError::BaseMethods

  class Error < StandardError
  end

  class MissingParameters < Error
    def initialize(parameters)
      super("Missing parameters: #{parameters.join(', ')}")
    end
  end

  class << self
    # @param params [Hash,ActionController::Parameters]
    def call(params = {})
      new(params).call
    end

    # @param name [Symbol]
    # @param required [Boolean] default false
    def parameter(name, required: false)
      attr_accessor(name)
      _required_parameters.push(name) if required
    end

    def inherited(subclass)
      subclass._required_parameters = _required_parameters.dup
      super
    end
  end

  class_attribute :logger, instance_writer: false, default: Rails.logger
  class_attribute :_required_parameters, instance_writer: false, default: []

  # @param params [Hash,ActionController::Parameters]
  def initialize(params = {})
    missing_parameters = _required_parameters - params.keys.map(&:to_sym)
    raise MissingParameters, missing_parameters if missing_parameters.any?

    assign_params(params)
  end

  def capture_tags
    { component: 'Service', service_name: self.class.name }
  end

  def call
    raise NotImplementedError
  end

  private

  def assign_params(params)
    params.each do |key, value|
      public_send("#{key}=", value)
    end
  end
end
