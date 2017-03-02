ActiveAdmin.register Importing::CodecGroup do

  filter :name

  acts_as_import_preview

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :name
  end

end
