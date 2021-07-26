# frozen_string_literal: true

module Importing
  class BaseDecorator < ::ApplicationDecorator
    def self.inherited(subclass)
      super

      # Defines import attributes to distinguish what attribute was changed.
      # For association keys association getter is decorated.
      subclass.object_class.import_attributes.each do |column_name|
        subclass.define_imported_column(column_name)
      end
    end

    # Imported column will be formatted and show whether it changed or not.
    def self.define_imported_column(column_name)
      column_name = column_name.to_s

      if import_assoc_keys.include?(column_name)
        assoc_name = column_name.gsub(/_id\z/, '')
        define_method(assoc_name) do
          wrap_changed_column(column_name) { association_value(assoc_name) }
        end
        return
      end

      define_method(column_name) do
        wrap_changed_column(column_name) { column_value(column_name) }
      end
    end

    # Shows whether routing tags column changed or not
    def routing_tags_column(column_name, name_column:)
      col_value = model.public_send(column_name)
      value = col_value.present? ?
                  Routing::RoutingTag.where(id: col_value).pluck(:name).join(', ') :
                  model.public_send(name_column)

      wrap_changed_column(column_name) { value }
    end

    # Formats o_id as link to import_object is possible.
    def o_id
      return if model.o_id.nil?
      return model.o_id if model.import_object.nil?

      h.auto_link(model.import_object, model.o_id.to_s)
    end

    private

    # Formats association value
    def association_value(assoc_name)
      value = model.public_send(assoc_name)
      name = model.public_send("#{assoc_name}_name")
      return h.auto_link(value, name) unless value.nil?

      name.presence || status_tag(:empty)
    end

    # Formats column value
    def column_value(column_name)
      value = model.public_send(column_name)
      return status_tag(:yes) if value == true
      return status_tag(:no) if value == false
      return status_tag(:empty) if value.presence.nil?

      value.to_s
    end

    # highlights value with orange background if it's changed.
    def wrap_changed_column(column_name)
      classes = column_changed?(column_name) ? 'import-col changed' : 'import-col'
      h.content_tag(:span, class: classes) { yield }
    end

    # @return [Boolean, nil] whether column value is distinct from import_object,
    #   or nil when import_object is nil.
    def column_changed?(column_name)
      return if model.o_id.nil? || model.import_object.nil?

      value = model.public_send(column_name)
      dst_value = model.import_object.public_send(column_name)
      value != dst_value
    end
  end
end
