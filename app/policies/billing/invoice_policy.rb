# frozen_string_literal: true

module Billing
  class InvoicePolicy < ::RolePolicy
    section 'Billing/Invoice'

    alias_rule :approve?, :regenerate_document?, to: :perform?
    # PDF access follows read: anyone who can view the invoice can view its PDF
    # (show-page tab, pdf?) and download it (export_file_pdf?) — it is the same
    # data the show page already exposes.
    alias_rule :pdf?, :export_file_pdf?, to: :read?

    # Reference is the only mutable field on an invoice, and only while pending.
    # #change_reference? backs the dedicated member action (and its show-page
    # sidebar), so the whole edit surface stays behind the update permission and
    # the pending-only state check.
    def update?
      record.state.pending? && super
    end

    def change_reference?
      update?
    end

    class Scope < ::RolePolicy::Scope
    end
  end
end
