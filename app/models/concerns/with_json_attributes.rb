# frozen_string_literal: true

module WithJsonAttributes
  # Wraps JSON column into a model.
  # @see JsonAttributeModel
  # @see JsonAttributeType
  # Usage:
  #
  #   class JsonAttributeModel::UserConfig < JsonAttributeModel::Base
  #     attribute :rate_limit, :integer
  #     attribute :max_per_page, :integer
  #
  #     validates :rate_limit, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than: 6_000 }
  #     validates :max_per_page, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  #   end
  #
  #   class User < ApplicationRecord
  #     include WithJsonAttributes
  #     json_attribute :config, class_name: 'JsonAttributeModel::UserConfig'
  #   end
  #
  #   customer = customer.create(config: { rate_limit: 6_001, max_per_page: 10 })
  #   customer.persisted? # false
  #   customer.errors.messages # { 'config.rate_limit': ['must be less than 6000'] }
  #   customer.config.rate_limit = 600
  #   customer.save # true
  #   customer.where(id: customer.id).pluck(:config).first # "{\"rate_limit\":600,\"max_per_page\":10}"

  extend ActiveSupport::Concern

  class_methods do
    # Defines json model attribute for provided column
    # @param name [Symbol] - name of json column (required)
    # @param class_name [String] - class name of corresponding model (required)
    def json_attribute(name, class_name:)
      attribute name, :json_object, class_name: class_name

      define_method("build_#{name}") do |attributes = {}|
        class_name.constantize.new(attributes)
      end
    end
  end
end
