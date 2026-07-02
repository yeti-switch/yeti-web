# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_templates
#
#  id            :integer(4)       not null, primary key
#  data          :binary
#  filename      :string
#  html_template :text
#  name          :string           not null
#  sha1          :string
#  created_at    :timestamptz
#
# Indexes
#
#  invoices_templates_name_key  (name) UNIQUE
#

class Billing::InvoiceTemplate < ApplicationRecord
  self.table_name = 'invoice_templates'
  # attr_accessible :template_file,:data,:name
  validates :name, presence: true
  validates :name, uniqueness: true

  # filename is ODT-specific; only enforce the .odt shape when a file was
  # uploaded. HTML-only templates (html_template present, no data) skip it.
  validates :filename, format: { with: /\A(.*\.odt)\z/ }, allow_blank: true

  # A template must provide something to render: either an ODT file (identified
  # by its filename) or an HTML template.
  validate :template_source_present

  # Keep sha1 in sync with the HTML template (used for display / change
  # detection); the ODT path sets sha1 from the uploaded file in template_file=.
  before_validation :refresh_html_sha1, if: :html_template_changed?

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

  private

  def template_source_present
    return if filename.present? || html_template.present?

    errors.add(:base, 'either an ODT template file or an HTML template is required')
  end

  def refresh_html_sha1
    self.sha1 = html_template.present? ? Digest::SHA1.hexdigest(html_template) : nil
  end
end
