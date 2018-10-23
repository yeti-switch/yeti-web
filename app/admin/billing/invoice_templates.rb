ActiveAdmin.register Billing::InvoiceTemplate, as: 'InvoiceTemplate' do
  menu parent: "Billing", label: "Invoice templates", priority: 40
  config.batch_actions = false
  actions :all #:index,:create, :new, :destroy, :delete, :edit, :update
  before_action :left_sidebar!

  permit_params :name, :template_file

  acts_as_export :id, :name,
                 [:file_name, proc { |row| row.filename}],
                 :created_at,
                 :sha1

  member_action :download, method: :get do
    send_data resource.get_file(resource.id), type: 'application/vnd.oasis.opendocument.text', filename: resource.filename
  end

  controller do
    def scoped_collection
      super.select('created_at, sha1, id, name, filename')
    end

    def find_resource
      scoped_collection.except(:select).find(params[:id])
    end

  end

  index do
    id_column
    actions
    # column :actions, defaults: false do  |row|
    #   link_to 'Delete', resource_path(row), method: :delete, data: {confirm: I18n.t('active_admin.delete_confirmation')}, class: "member_link delete_link"
    # end

    column :name

    column "File" do |filelink|
      link_to filelink.filename, download_invoice_template_path(filelink), method: :get
    end
    column :created_at
    column :sha1
  end

  filter :id, as: :numeric
  filter :name
  filter :filename

  form do |f|
    f.semantic_errors *f.object.errors.keys.uniq
    f.inputs form_title do
      f.input :name
      f.input :template_file, as: :file
    end
    panel "test" do
      "You can use next placeholders:"
      table_for InvoiceDocs.replaces_list.each do |x|
        column :placeholder do |c|
          strong do
          "[#{c.to_s.upcase}]"
          end

        end
        column :description do |c|
          I18n.t('invoice_template.placeholders.'+c.to_s)
        end
      end
    end

    f.actions
end


  show do |t|
    attributes_table do
      row :id
      row :name
      row :sha1
      row :created_at
    end

    active_admin_comments
  end

end
