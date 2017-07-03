class InvoiceGenerator

  attr_reader :billing_invoice

  def initialize(invoice)
    @billing_invoice = invoice
  end

  def save!
    @billing_invoice.transaction do
      @billing_invoice.save!
      @billing_invoice.reload # need reload because data changed in after_create callback
      begin
        InvoiceDocs.new(@billing_invoice).save!
      rescue InvoiceDocs::TemplateUndefined => e
         Rails.logger.info { e.message }
      end
    end
    @billing_invoice
  end

end