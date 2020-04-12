# frozen_string_literal: true

ActiveAdmin.register Importing::CodecGroup do
  filter :name
  boolean_filter :is_changed

  acts_as_import_preview

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :is_changed

    column :name
  end
end
