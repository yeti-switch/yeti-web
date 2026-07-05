# frozen_string_literal: true

# Removes the legacy ODT template storage from billing.invoice_templates now
# that invoices are rendered exclusively from html_template via yeti-pdf.
# Before dropping, the raw ODT blobs are dumped to files (override the
# destination with INVOICE_ODT_DUMP_DIR) so the originals are preserved.
class DropOdtColumnsFromInvoiceTemplates < ActiveRecord::Migration[7.2]
  # Throwaway model: read the blobs without depending on the app model (which
  # loses these columns after this migration) and get `data` back as binary.
  class LegacyTemplate < ActiveRecord::Base
    self.table_name = 'billing.invoice_templates'
  end

  def up
    dump_odt_templates
    remove_column 'billing.invoice_templates', :data
    remove_column 'billing.invoice_templates', :filename
    remove_column 'billing.invoice_templates', :sha1
  end

  def down
    add_column 'billing.invoice_templates', :sha1, :string
    add_column 'billing.invoice_templates', :filename, :string
    add_column 'billing.invoice_templates', :data, :binary
  end

  private

  def dump_odt_templates
    scope = LegacyTemplate.where.not(data: nil)
    count = scope.count
    return say('No ODT template blobs to dump') if count.zero?

    dir = ENV.fetch('INVOICE_ODT_DUMP_DIR', Rails.root.join('tmp/invoice_odt_backup').to_s)
    require 'fileutils'
    FileUtils.mkdir_p(dir)
    say("Dumping #{count} ODT template(s) to #{dir}")
    scope.find_each do |t|
      base = t.filename.presence || "#{t.name}.odt"
      path = File.join(dir, "#{t.id}_#{base}")
      File.binwrite(path, t.data)
      say("##{t.id} #{t.name} -> #{path} (#{t.data.bytesize} bytes)", true)
    end
  end
end
