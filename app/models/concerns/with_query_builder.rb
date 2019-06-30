# frozen_string_literal: true

module WithQueryBuilder
  extend ActiveSupport::Concern

  included do
    class_attribute :query_builder_name, instance_accessor: false, default: 'QueryBuilder::Proxy'

    extend SingleForwardable
    extend Forwardable

    singleton_class.send :alias_method, :all, :query_builder
    single_delegate %i[to_a where includes none find] => :all
  end

  class_methods do
    def query_builder_class
      query_builder_name.constantize
    end

    def query_builder
      query_builder_class.new(self)
    end
  end
end
