ActiveAdmin.register CodecGroup do
  menu parent: "Equipment", priority: 90

  acts_as_audit
  acts_as_clone :codec_group_codecs
  acts_as_safe_destroy

  acts_as_export :id, :name

  permit_params :name,
                codec_group_codecs_attributes: [
                   :id, :codec_id, :priority, :dynamic_payload_type, :format_parameters, :_destroy
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
    column :codecs do |row|
      codec_names =  row.codec_names

      div  class: :has_tooltip , title: codec_names.join(",") do
         if  codec_names.size > 3
           row.codec_names.take(3).join(" ") << '...'
         else
            row.codec_names.join(' ')
         end

      end

    end
  end

  filter :id
  filter :name

  form do |f|
    f.semantic_errors *f.object.errors.keys.uniq
    f.inputs form_title do
      f.input :name, hint: I18n.t('hints.equipment.codec_group.name')
    end

    f.inputs "Codecs" do
        f.has_many :codec_group_codecs do |t|

            t.input :codec_id, as: :select, collection: Codec.all , input_html: { class: 'chosen'}, hint: I18n.t('hints.equipment.codec_group.codec_id')
            t.input :priority, hint: I18n.t('hints.equipment.codec_group.priority')
            t.input :dynamic_payload_type, hint: I18n.t('hints.equipment.codec_group.dynamic_payload_type')
            t.input :format_parameters, hint: I18n.t('hints.equipment.codec_group.format_parameters')
            t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless  t.object.new_record?

        end
      end
    f.actions
  end

  show do |s|
    attributes_table do
      row :id
      row :name
    end

    panel "Codecs" do
      table_for s.codec_group_codecs.includes(:codec).order("priority desc") do
        column :priority
        column :codec
        column :dynamic_payload_type
        column :format_parameters
      end
    end

  end

end
