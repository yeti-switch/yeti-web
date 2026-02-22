# frozen_string_literal: true

ActiveAdmin.register CodecGroup do
  menu parent: 'Equipment', priority: 90

  acts_as_audit
  acts_as_clone duplicates: [:codec_group_codecs]
  acts_as_safe_destroy

  acts_as_export :id, :name, :ptime

  permit_params :name, :ptime,
                codec_group_codecs_attributes: %i[
                  id codec_id priority dynamic_payload_type format_parameters _destroy
                ]

  controller do
    def scoped_collection
      super.eager_load(codec_group_codecs: [:codec])
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :ptime
    column :codecs do |row|
      codec_names = row.codec_names

      with_tooltip(codec_names.join(',')) do
        if codec_names.size > 3
          row.codec_names.take(3).join(' ') << '...'
        else
          row.codec_names.join(' ')
        end
      end
    end
  end

  filter :id
  filter :name
  filter :ptime

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :ptime, hint: "Allowed values: #{CodecGroup::ALLOWED_PTIMES.join(', ')}. Leave empty to use value announced by other leg"
    end

    f.inputs 'Codecs' do
      f.has_many :codec_group_codecs do |t|
        t.input :codec_id, as: :select, collection: Codec.all, input_html: { class: 'tom-select' }
        t.input :priority
        t.input :dynamic_payload_type, hint: 'Payload type must be between 96 and 127'
        t.input :format_parameters
        t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless t.object.new_record?
      end
    end
    f.actions
  end

  show do |s|
    attributes_table do
      row :id
      row :name
      row :ptime
    end

    panel 'Codecs' do
      table_for s.codec_group_codecs.includes(:codec).order('priority desc') do
        column :priority
        column :codec
        column :dynamic_payload_type
        column :format_parameters
      end
    end
  end
end
