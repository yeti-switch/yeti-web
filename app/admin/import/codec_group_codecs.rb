# frozen_string_literal: true

ActiveAdmin.register Importing::CodecGroupCodec do
  filter :codec_group, input_html: { class: 'tom-select' }
  filter :codec
  boolean_filter :is_changed

  acts_as_import_preview

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :is_changed

    column :codec_group, sortable: :codec_group_name
    column :codec, sortable: :codec_name
    column :priority
  end
end
