# frozen_string_literal: true

ActiveAdmin.register Importing::CodecGroupCodec do
  filter :codec_group, input_html: { class: 'chosen' }
  filter :codec

  acts_as_import_preview

  controller do
    def scoped_collection
      super.includes(:codec_group, :codec)
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :codec_group, sortable: :codec_group_name do |row|
      if row.codec_group.blank?
        row.codec_group_name
      else
        auto_link(row.codec_group, row.codec_group_name)
      end
    end

    column :codec, sortable: :codec_name do |row|
      if row.codec.blank?
        row.codec_name
      else
        auto_link(row.codec, row.codec_name)
      end
    end

    column :priority
  end
end
