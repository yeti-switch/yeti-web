# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_templates
#
#  id         :integer(4)       not null, primary key
#  data       :binary
#  filename   :string           not null
#  name       :string           not null
#  sha1       :string
#  created_at :datetime
#
# Indexes
#
#  invoices_templates_name_key  (name) UNIQUE
#

class Billing::InvoiceTemplate < Yeti::ActiveRecord
  self.table_name = 'invoice_templates'
  # attr_accessible :template_file,:data,:name
  validates :name, presence: true
  validates :name, uniqueness: true

  validates :filename, format: { with: /\A(.*\.odt)\z/ }

  def template_file=(uploaded_file)
    self.filename = uploaded_file.original_filename
    self.data = uploaded_file.read
    self.sha1 = Digest::SHA1.hexdigest(data)
    # self.upload_date=Time.now
  end

  # TODO: remove
  def get_file(id)
    Billing::InvoiceTemplate.find(id).data
  end

  def display_name
    name
  end
end
