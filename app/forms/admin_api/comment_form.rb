# frozen_string_literal: true

module AdminApi
  class CommentForm < ProxyForm
    with_model_name 'ActiveAdmin::Comment'
    model_class 'ActiveAdmin::Comment'

    model_attributes :body, :resource_id, :author

    attribute :resource_type, :string

    validates :resource_type, inclusion: { in: ->(_form) { commentable_types } }

    after_initialize { model.namespace = self.class.namespace_name.to_s }

    # ActiveAdmin falls back to the :root namespace when default_namespace is false
    def self.namespace_name
      ActiveAdmin.application.default_namespace || :root
    end

    # @return [Array<String>] resource types that can be commented on in ActiveAdmin
    def self.commentable_types
      ActiveAdmin.application.namespaces[namespace_name].resources
                 .select { |resource| resource.is_a?(ActiveAdmin::Resource) && resource.comments? }
                 .select { |resource| resource.resource_class < ActiveRecord::Base }
                 .map { |resource| resource.resource_class.base_class.name }
                 .uniq
    end

    # Model's polymorphic resource_type is constantized on validation,
    # so only commentable types are passed to it.
    def resource_type=(value)
      super
      model.resource_type = self.class.commentable_types.include?(value) ? value : nil
    end
  end
end
