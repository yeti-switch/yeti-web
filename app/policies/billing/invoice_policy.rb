# frozen_string_literal: true

module Billing
  class InvoicePolicy < ::RolePolicy
    section 'Billing/Invoice'

    alias_rule :approve?, :regenerate_document?, to: :perform?
    alias_rule :export_file_odt?, :export_file_csv?, :export_file_xls?, :export_file_pdf?, to: :perform?
    # Inline PDF view for the show-page "PDF" tab: it renders the same invoice
    # data the show page already exposes, so it follows read (not the perform?
    # rule the file downloads use).
    alias_rule :pdf?, to: :read?

    class Scope < ::RolePolicy::Scope
    end
  end
end
