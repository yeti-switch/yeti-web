# frozen_string_literal: true

# yeti-pdf is now the only invoice renderer, so invoice_documents no longer
# stores anything besides the PDF: the `data` column previously held the ODT
# bytes (legacy) or the merged HTML (debug), neither of which is read. A new
# invoices.pdf_error column records the last document-generation failure so it
# can be surfaced in the UI.
class InvoiceDocumentPdfOnly < ActiveRecord::Migration[7.2]
  def up
    remove_column 'billing.invoice_documents', :data
    add_column 'billing.invoices', :pdf_error, :text
  end

  def down
    remove_column 'billing.invoices', :pdf_error
    add_column 'billing.invoice_documents', :data, :binary
  end
end
