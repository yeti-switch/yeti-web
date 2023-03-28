# frozen_string_literal: true

# Adds ability to use array attributes in active model.
# Should be included after ActiveModel::Attributes.
# @see ArrayType
# @example
#
#   class EmailsModel
#     include ActiveModel::Model
#     include ActiveModel::Attributes
#     include WithActiveModelArrayAttribute
#
#     attribute :data_columns, :string, array: { reject_blank: true }
#     attribute :user_ids, :integer, array: true
#   end
#
module WithActiveModelArrayAttribute
  extend ActiveSupport::Concern

  class_methods do
    def attribute(name, type = ActiveModel::Type::Value.new, array: false, **options)
      if array
        array_opts = array.is_a?(TrueClass) ? {} : array
        subtype = type.is_a?(Symbol) ? ActiveModel::Type.lookup(type, **options.except(:default)) : type
        type = ArrayType.new(subtype, **array_opts)
      end
      super(name, type, **options)
    end
  end
end
