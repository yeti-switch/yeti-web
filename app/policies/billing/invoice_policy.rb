module Billing
  class InvoicePolicy < ::RolePolicy
    section 'Billing/Invoice'

    alias_rule :approve?, :regenerate_document?, to: :perform?
    alias_rule :export_file_odt?, :export_file_csv?, :export_file_xls?, :export_file_pdf?, to: :perform?

    class Scope < ::RolePolicy::Scope
    end

  end
end
  
