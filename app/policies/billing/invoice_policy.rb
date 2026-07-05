# frozen_string_literal: true

module Billing
  class InvoicePolicy < ::RolePolicy
    section 'Billing/Invoice'

    alias_rule :approve?, :regenerate_document?, to: :perform?
    # PDF access follows read: anyone who can view the invoice can view its PDF
    # (show-page tab, pdf?) and download it (export_file_pdf?) — it is the same
    # data the show page already exposes.
    alias_rule :pdf?, :export_file_pdf?, to: :read?

    class Scope < ::RolePolicy::Scope
    end
  end
end
