# frozen_string_literal: true

class InvoiceRefTemplate
  TEMPLATES = {
    '$id': proc { invoice.id }
  }.freeze

  def self.call(invoice, template)
    new(invoice, template).call
  end

  attr_reader :invoice, :template

  def initialize(invoice, template)
    @invoice = invoice
    @template = template
  end

  def call
    result = template
    TEMPLATES.each do |key, value_block|
      value = instance_exec(&value_block).to_s
      result = result.gsub(key.to_s, value)
    end
    result
  end
end
